import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/collection/hourly_bucket.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/collection/sample_source.dart';
import 'package:fl_clash/traffic_ledger/collection/traffic_diagnostics.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// 后台流量采集服务。仅在 FLClash 应用进程中运行，负责：
/// - 按固定间隔（默认 1 秒）从核心采样总代理流量 + 连接列表；
/// - 通过 [Reconciler] 计算增量并归因；
/// - 将已归因增量写入内存 [FlushBatch]；
/// - 按固定间隔（默认 15 秒）批量 flush 到 DAO；
/// - 核心停止/应用退出前尽力 flush；
/// - 不依赖 UI 页面是否打开。
///
/// 生命周期：
/// - [start]：核心启动/重启时调用，递增 generation，开始采样；
/// - [pauseAndFlush]：核心停止时调用，停止采样 + 立即 flush；
/// - [flushAndDispose]：应用退出前调用，最终 flush 并释放定时器。
///
/// 并发防护（Stage 3.1）：
/// - 采样操作互斥（同一时刻最多一个 _tick 在执行）；
/// - flush 操作互斥（同一时刻最多一个 _flush 在执行）；
/// - tick 内捕获 generation，await sample source 返回后若 generation
///   已变化则丢弃样本；
/// - flush 采用 swap-on-drain：写入 DAO 期间新增的 batch 不丢失；
/// - DAO 写入失败时数据 merge-back 保留。
class TrafficCollectionService {
  TrafficCollectionService({
    required TrafficSampleSource sampleSource,
    required CachedMultiplierResolver multiplierResolver,
    required BillingPeriodManager periodManager,
    required Reconciler reconciler,
    Duration samplingInterval = const Duration(seconds: 1),
    Duration flushInterval = const Duration(seconds: 15),
    DateTime Function() now = DateTime.now,
  })  : _sampleSource = sampleSource,
        _multiplierResolver = multiplierResolver,
        _periodManager = periodManager,
        _reconciler = reconciler,
        _samplingInterval = samplingInterval,
        _flushInterval = flushInterval,
        _now = now;

  final TrafficSampleSource _sampleSource;
  final CachedMultiplierResolver _multiplierResolver;
  final BillingPeriodManager _periodManager;
  final Reconciler _reconciler;
  final Duration _samplingInterval;
  final Duration _flushInterval;
  final DateTime Function() _now;

  /// 当前核心会话标识。每次 [start] 递增，用于检测核心重启。
  int _generation = 0;

  /// 采集状态（跨采样保持，仅在内存中）。
  CollectionState _state = const CollectionState();

  /// 待写聚合桶。
  final FlushBatch _pendingBatch = FlushBatch();

  /// 采样定时器。
  Timer? _samplingTimer;

  /// Flush 定时器。
  Timer? _flushTimer;

  /// 采样互斥锁：同一时刻最多一个 _tick 在执行。
  bool _samplingInFlight = false;

  /// Flush 互斥锁：同一时刻最多一个 _flush 在执行。
  bool _flushInFlight = false;

  /// 是否已 disposed（最终 flush 完成，不再接受新采样/flush）。
  bool _disposed = false;

  /// 是否正在运行（已 start 且未 pause/dispose）。
  bool get isRunning => _samplingTimer != null;

  /// 是否已完成首次基线建立。
  bool get baselineEstablished => _state.baselineEstablished;

  /// 待写桶中的维度数（用于诊断）。
  int get pendingBucketCount => _pendingBatch.length;

  /// 缓存的当前周期 ID + 所属小时，避免每秒查库。
  int? _cachedPeriodId;
  DateTime? _cachedPeriodCheckHour;

  /// 启动/恢复采样。每次调用递增 generation，确保 reconciler 检测到
  /// 核心会话切换并重建基线（不产生虚假增量）。
  ///
  /// 幂等：若已在运行，先取消现有定时器再重启。
  void start() {
    if (_disposed) {
      commonPrint.log(
        'TrafficCollectionService.start() called after dispose; ignored',
        logLevel: LogLevel.warning,
      );
      return;
    }
    if (_samplingTimer != null) {
      commonPrint.log(
        'TrafficCollectionService.start() called while running; '
        'treating as core restart',
      );
    }
    _generation++;
    _samplingTimer?.cancel();
    _flushTimer?.cancel();
    _samplingTimer = Timer.periodic(_samplingInterval, (_) => _tick());
    _flushTimer = Timer.periodic(_flushInterval, (_) => _tickFlush());
    TrafficDiagnostics.instance
        .recordLifecycle('start gen=$_generation');
    commonPrint.log(
      'TrafficCollectionService started (generation=$_generation)',
    );
  }

  /// 暂停采样并立即 flush 待写数据（Stage 3.1）。
  ///
  /// 语义：
  /// 1. 停止新的采样定时器；
  /// 2. 阻止新的 tick 再写入 pending batch（_samplingInFlight 完成后不再新增）；
  /// 3. 将当前 pending batch 立即持久化；
  /// 4. 保留活动计费周期和已建立的历史；
  /// 5. 不清零、不删除数据；
  /// 6. 下次 start 后仍进入同一个活动周期，但通过 generation 建立新基线。
  ///
  /// 用于核心停止（[SetupAction.handleStop]）和计费周期手动切换。
  Future<void> pauseAndFlush() async {
    if (_disposed) return;
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    commonPrint.log('TrafficCollectionService pauseAndFlush');
    TrafficDiagnostics.instance.recordLifecycle('pauseAndFlush begin');
    // 等待在飞的采样完成（避免数据写入已 drain 的 batch）。
    // 这里用轮询而非 Completer，因为 _tick 内部异常可能导致信号丢失。
    final waitSw = TrafficDiagnostics.instance.enabled
        ? (Stopwatch()..start())
        : null;
    while (_samplingInFlight) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    if (waitSw != null) {
      TrafficDiagnostics.instance
          .recordPauseAndFlushWait(waitSw.elapsedMilliseconds);
    }
    await _flush();
    TrafficDiagnostics.instance.recordLifecycle('pauseAndFlush end');
  }

  /// 最终 flush 并释放资源。应用退出前调用。
  ///
  /// 调用后服务进入 disposed 状态，后续 start() 被忽略。
  Future<void> flushAndDispose() async {
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    TrafficDiagnostics.instance.recordLifecycle('flushAndDispose begin');
    while (_samplingInFlight) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    await _flush();
    _disposed = true;
    // Stage 3.2: 应用退出前输出诊断汇总（仅 debug）。
    final summary = TrafficDiagnostics.instance.summarize();
    if (summary != 'diagnostics disabled (release)') {
      commonPrint.log('TrafficCollectionService diagnostics:\n$summary');
    }
    TrafficDiagnostics.instance.recordLifecycle('flushAndDispose end');
    commonPrint.log('TrafficCollectionService disposed');
  }

  /// 手动触发一次 flush（不影响定时器，不影响生命周期）。
  /// 用于计费周期手动切换等场景。
  Future<void> flush() => _flush();

  /// 用户手动"新建计费周期"的协调入口（Stage 3.2）。
  ///
  /// **UI 不应**分别调用 `flush()` + `billingPeriodManager.createNewPeriod()`，
  /// 因为两步之间可能有新的 tick 进入，导致旧样本写入新周期或新样本写回旧周期。
  ///
  /// 本方法串行完成：
  /// 1. 取消采样定时器（阻止新 tick）；
  /// 2. 等待在飞采样结束（避免 race）；
  /// 3. flush 当前 pending batch（旧周期数据归旧周期）；
  /// 4. 调用 [BillingPeriodManager.createNewPeriod] 创建新周期；
  /// 5. 清理 period cache（_cachedPeriodId/CheckHour），强制下次采样重新解析；
  /// 6. 递增 generation（让 reconciler 在下次采样时仅建立新基线，不产生增量）；
  /// 7. 恢复采样定时器（若服务原本在运行）。
  ///
  /// 不清零历史；旧周期数据保留。过程不可让旧样本写入新周期。
  /// [label] / [startAt] 透传给 [BillingPeriodManager.createNewPeriod]。
  Future<TrafficBillingPeriod> createNewBillingPeriod({
    String? label,
    DateTime? startAt,
  }) async {
    if (_disposed) {
      throw StateError('createNewBillingPeriod called after dispose');
    }
    final wasRunning = _samplingTimer != null;
    // 1. 取消采样定时器。
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    TrafficDiagnostics.instance.recordLifecycle('createNewBillingPeriod begin');
    try {
      // 2. 等待在飞采样。
      while (_samplingInFlight) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      // 3. flush 当前 pending batch（旧样本归旧周期）。
      await _flush();
      // 4. 创建新周期。
      final newPeriod = await _periodManager.createNewPeriod(
        label: label,
        startAt: startAt,
      );
      // 5. 清理 period cache，强制下次采样重新解析到新周期。
      _cachedPeriodId = null;
      _cachedPeriodCheckHour = null;
      // 6. 递增 generation：reconciler 检测到变化后仅建立新基线，
      //    不把旧核心累计字节当成增量。
      _generation++;
      TrafficDiagnostics.instance.recordLifecycle(
        'createNewBillingPeriod end gen=$_generation periodId=${newPeriod.id}',
      );
      return newPeriod;
    } finally {
      // 7. 若服务原本在运行，恢复采样定时器。
      if (wasRunning && !_disposed) {
        _samplingTimer = Timer.periodic(_samplingInterval, (_) => _tick());
        _flushTimer = Timer.periodic(_flushInterval, (_) => _tickFlush());
      }
    }
  }

  /// 手动触发一次采样（测试用）。不依赖定时器。
  @visibleForTesting
  Future<void> sampleOnce() => _tick();

  /// 手动触发一次 flush（测试用）。不依赖定时器。
  @visibleForTesting
  Future<void> flushOnce() => _flush();

  /// 当前 generation（测试诊断用）。
  @visibleForTesting
  int get generation => _generation;

  /// 采样定时器回调。
  Future<void> _tick() async {
    if (_disposed) return;
    // 互斥：同一时刻最多一个采样在执行。
    if (_samplingInFlight) return;
    _samplingInFlight = true;
    final diag = TrafficDiagnostics.instance;
    final sw = diag.enabled ? (Stopwatch()..start()) : null;
    try {
      // 捕获当前 generation，await 后用于检测是否过期。
      final tickGeneration = _generation;
      final observedAt = _now();
      final sample = await _sampleSource.collect(now: observedAt);
      if (sample == null) {
        // 核心未就绪或采样失败：跳过，不更新状态。
        return;
      }
      // 过期样本检测：await 期间若已 pause/dispose/generation 变化，丢弃。
      if (_disposed || _generation != tickGeneration) {
        commonPrint.log(
          'TrafficCollectionService: stale sample discarded '
          '(disposed=$_disposed, gen $tickGeneration -> $_generation)',
        );
        return;
      }

      // 刷新倍率缓存（仅新节点会查库）。
      final nodeNames = sample.connections
          .where((c) => c.isProxy && c.nodeName.isNotEmpty)
          .map((c) => c.nodeName)
          .toSet();
      if (nodeNames.isNotEmpty) {
        await _multiplierResolver.refreshFor(nodeNames);
      }

      // 过期检测：refreshFor 也有 await，可能跨过 pause/dispose。
      if (_disposed || _generation != tickGeneration) {
        commonPrint.log(
          'TrafficCollectionService: stale sample discarded after refresh',
        );
        return;
      }

      // Reconcile：计算增量并归因。
      final result = _reconciler.reconcile(
        sample: sample,
        state: _state,
        currentGeneration: _generation,
      );
      _state = result.newState;

      // 输出诊断信息（overflow、核心重启等）。
      for (final diag in result.diagnostics) {
        commonPrint.log('TrafficCollectionService: $diag');
      }

      // 将增量写入待写桶。每个 delta 用其 observedAt 决定归属周期。
      if (result.attributedDeltas.isNotEmpty) {
        final periodId = await _resolvePeriodId(observedAt);
        if (_disposed || _generation != tickGeneration) {
          commonPrint.log(
            'TrafficCollectionService: deltas discarded after period resolve',
          );
          return;
        }
        if (periodId != null) {
          for (final delta in result.attributedDeltas) {
            _pendingBatch.add(
              periodId: periodId,
              observedAt: observedAt,
              delta: delta,
            );
          }
        }
      }
    } catch (e, s) {
      commonPrint.log(
        'TrafficCollectionService sample error: $e\n$s',
        logLevel: LogLevel.error,
      );
    } finally {
      if (sw != null) {
        diag.recordTick(sw.elapsedMilliseconds);
      }
      _samplingInFlight = false;
    }
  }

  /// Flush 定时器回调。
  Future<void> _tickFlush() => _flush();

  /// 将待写桶批量写入 DAO。
  ///
  /// 并发安全（Stage 3.1）：
  /// - 互斥锁 _flushInFlight 防止同时多个 flush；
  /// - swap-on-drain：写入期间新增的 batch 不丢失；
  /// - DAO 写入失败时 merge-back 保留数据。
  Future<void> _flush() async {
    if (_disposed) return;
    if (_flushInFlight) return;
    if (_pendingBatch.isEmpty) return;
    _flushInFlight = true;
    try {
      final flushAt = _now();
      // swap：取出当前 batch 内容，新 batch 接收后续增量。
      final stats = _pendingBatch.drain(updatedAt: flushAt);
      if (stats.isEmpty) return;
      try {
        await _periodManager.upsertHourlyStats(stats);
      } catch (e, s) {
        // DAO 写入失败：merge-back，将数据放回 batch 顶部。
        commonPrint.log(
          'TrafficCollectionService flush failed, merging back: $e\n$s',
          logLevel: LogLevel.error,
        );
        _pendingBatch.mergeBack(stats);
      }
    } catch (e, s) {
      commonPrint.log(
        'TrafficCollectionService flush error: $e\n$s',
        logLevel: LogLevel.error,
      );
    } finally {
      _flushInFlight = false;
    }
  }

  /// 解析采样时刻所属的计费周期 ID。
  ///
  /// 缓存策略：billingCycleDay 边界必然在整点（billingCycleHour=0），
  /// 因此同一小时内周期不会切换。仅在跨小时时重新调用
  /// [BillingPeriodManager.ensureActivePeriod]。
  Future<int?> _resolvePeriodId(DateTime observedAt) async {
    final hour = DateTime(
      observedAt.year,
      observedAt.month,
      observedAt.day,
      observedAt.hour,
    );
    if (_cachedPeriodId != null && _cachedPeriodCheckHour == hour) {
      return _cachedPeriodId;
    }
    try {
      final period = await _periodManager.ensureActivePeriod(now: observedAt);
      _cachedPeriodId = period.id;
      _cachedPeriodCheckHour = hour;
      return period.id;
    } catch (e, s) {
      commonPrint.log(
        'TrafficCollectionService resolve period error: $e\n$s',
        logLevel: LogLevel.error,
      );
      return _cachedPeriodId; // 降级使用上次缓存
    }
  }
}
