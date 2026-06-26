import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/collection/hourly_bucket.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/collection/sample_source.dart';
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
/// - [pause]：核心停止时调用，停止采样但保留状态，flush 待写数据；
/// - [flushAndDispose]：应用退出前调用，最终 flush 并释放定时器。
///
/// 采样时间决定周期归属（见 Stage 3 需求六）：
/// - 每次采样用 `observedAt` 调用 [BillingPeriodManager.ensureActivePeriod]；
/// - flush 时刻不影响样本归属周期；
/// - 缓存当前 periodId + hourStart，仅在跨小时时重新查询。
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

  /// 是否正在采样（已 start 且未 pause/dispose）。
  bool get isRunning => _samplingTimer != null;

  /// 是否已完成首次基线建立。
  bool get baselineEstablished => _state.baselineEstablished;

  /// 待写桶中的维度数（用于诊断）。
  int get pendingBucketCount => _pendingBatch.length;

  /// 缓存的当前周期 ID + 所属小时，避免每秒查库。
  /// 跨小时（billingCycleDay 边界必然在整点）时重新查询。
  int? _cachedPeriodId;
  DateTime? _cachedPeriodCheckHour;

  /// 启动/恢复采样。每次调用递增 generation，确保 reconciler 检测到
  /// 核心会话切换并重建基线（不产生虚假增量）。
  ///
  /// 幂等：若已在运行，先取消现有定时器再重启。
  void start() {
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
    commonPrint.log(
      'TrafficCollectionService started (generation=$_generation)',
    );
  }

  /// 暂停采样。停止定时器但保留采集状态（基线、generation）。
  /// flush 待写数据以最小化数据丢失窗口。
  ///
  /// 核心再次 [start] 时会递增 generation，reconciler 自动重建基线。
  Future<void> pause() async {
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    commonPrint.log('TrafficCollectionService paused');
    // 暂停时 flush 待写数据，避免应用崩溃丢失。
    await _flush();
  }

  /// 最终 flush 并释放资源。应用退出前调用。
  Future<void> flushAndDispose() async {
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    await _flush();
    commonPrint.log('TrafficCollectionService disposed');
  }

  /// 手动触发一次 flush（不影响定时器）。
  Future<void> flush() => _flush();

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
    try {
      final observedAt = _now();
      final sample = await _sampleSource.collect(now: observedAt);
      if (sample == null) {
        // 核心未就绪或采样失败：跳过，不更新状态。
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
    }
  }

  /// Flush 定时器回调。
  Future<void> _tickFlush() => _flush();

  /// 将待写桶批量写入 DAO。空桶时跳过。
  Future<void> _flush() async {
    if (_pendingBatch.isEmpty) return;
    try {
      final flushAt = _now();
      final stats = _pendingBatch.drain(updatedAt: flushAt);
      if (stats.isEmpty) return;
      // 注意：upsertHourlyStats 内部按主键 upsert + 累加，
      // 不需要外层 transaction（Drift 自动批处理）。
      await _periodManager.upsertHourlyStats(stats);
    } catch (e, s) {
      commonPrint.log(
        'TrafficCollectionService flush error: $e\n$s',
        logLevel: LogLevel.error,
      );
      // flush 失败时数据已 drain 出桶，无法回滚。
      // 接受丢失这一窗口的增量（Stage 3 需求八的已知限制）。
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
