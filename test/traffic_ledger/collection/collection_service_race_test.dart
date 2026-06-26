import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/collection/collection_service.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/collection/sample_source.dart';
import 'package:fl_clash/traffic_ledger/node_multiplier_service.dart';
import 'package:test/test.dart';

/// 可控延迟的采样数据源：collect() 通过 completer 暂停，
/// 测试代码显式 complete 后才返回，用于模拟 await 期间发生 pause/dispose。
class _ControllableSampleSource implements TrafficSampleSource {
  _ControllableSampleSource();

  // 排队等待的 completer。collect 调用时创建一个，测试代码 complete 它。
  final List<_PendingCollect> _pending = [];

  @override
  Future<TrafficSample?> collect({DateTime? now}) async {
    final requestedAt = now ?? DateTime.now();
    final p = _PendingCollect(requestedAt);
    _pending.add(p);
    return p.completer.future.then((sample) {
      if (sample == null) return null;
      // 用调用方传入的 now 覆盖 observedAt，确保时钟可控。
      return TrafficSample(
        observedAt: requestedAt,
        totalProxyUp: sample.totalProxyUp,
        totalProxyDown: sample.totalProxyDown,
        connections: sample.connections,
      );
    });
  }

  /// 完成 queue 中第一个 pending collect，返回其样本。
  void complete(TrafficSample? sample) {
    if (_pending.isEmpty) {
      throw StateError('no pending collect');
    }
    _pending.removeAt(0).completer.complete(sample);
  }

  int get pendingCount => _pending.length;
}

class _PendingCollect {
  _PendingCollect(this.requestedAt);
  final DateTime requestedAt;
  final completer = Completer<TrafficSample?>();
}

TrafficSample _sample({
  required DateTime observedAt,
  required int totalProxyUp,
  required int totalProxyDown,
  List<ConnectionSnapshot> connections = const [],
}) {
  return TrafficSample(
    observedAt: observedAt,
    totalProxyUp: totalProxyUp,
    totalProxyDown: totalProxyDown,
    connections: connections,
  );
}

Database _createInMemoryDb() => Database(NativeDatabase.memory());

void main() {
  late Database db;
  late TrafficLedgerDao dao;
  late BillingPeriodManager periodManager;
  late NodeMultiplierService multiplierService;
  late CachedMultiplierResolver multiplierResolver;
  late Reconciler reconciler;
  late DateTime now;

  setUp(() {
    db = _createInMemoryDb();
    dao = db.trafficLedgerDao;
    periodManager = BillingPeriodManager(dao);
    multiplierService = NodeMultiplierService(dao);
    multiplierResolver = CachedMultiplierResolver(multiplierService);
    reconciler = Reconciler(multiplierResolver: multiplierResolver);
    now = DateTime(2026, 6, 27, 10, 0, 0);
  });
  tearDown(() => db.close());

  TrafficCollectionService createServiceWithSource(
    TrafficSampleSource source,
  ) {
    return TrafficCollectionService(
      sampleSource: source,
      multiplierResolver: multiplierResolver,
      periodManager: periodManager,
      reconciler: reconciler,
      samplingInterval: const Duration(hours: 1),
      flushInterval: const Duration(hours: 1),
      now: () => now,
    );
  }

  group('pauseAndFlush 立即持久化', () {
    test('未等到 15 秒定时 flush，pauseAndFlush 立即写入 DAO', () async {
      final source = _ControllableSampleSource();
      final service = createServiceWithSource(source);

      // 基线采样。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      final baselineFuture = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await baselineFuture;
      expect(service.baselineEstablished, true);

      // 增量采样。
      now = DateTime(2026, 6, 27, 10, 0, 1);
      final deltaFuture = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 2000,
        connections: const [],
      ));
      await deltaFuture;
      expect(service.pendingBucketCount, greaterThan(0));

      // 调用 pauseAndFlush（不等待定时器）。
      await service.pauseAndFlush();

      // 验证数据已写入 DAO。
      final period = await periodManager.getActivePeriod();
      expect(period, isNotNull);
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      expect(stats, isNotEmpty);
      // 总代理 1000 up + 2000 down 全部进未归因。
      final unattributed = stats.where(
        (s) => s.appIdentifier == unattributedAppIdentifier,
      );
      expect(unattributed, isNotEmpty);
      expect(unattributed.first.bytesUp, 1000);
      expect(unattributed.first.bytesDown, 2000);
    });

    test('暂停后不再采样、不重复写入', () async {
      final source = _ControllableSampleSource();
      final service = createServiceWithSource(source);

      // 基线。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      final f1 = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      ));
      await f1;

      // 增量 + pauseAndFlush。
      now = DateTime(2026, 6, 27, 10, 0, 1);
      final f2 = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 2000,
        connections: const [],
      ));
      await f2;
      await service.pauseAndFlush();

      final period = await periodManager.getActivePeriod();
      final statsBefore = await dao.queryHourlyStats(periodId: period!.id).get();
      final sumUpBefore = statsBefore.fold<int>(0, (s, x) => s + x.bytesUp);

      // 再次调用 pauseAndFlush（不应重复写入）。
      await service.pauseAndFlush();
      final statsAfter = await dao.queryHourlyStats(periodId: period.id).get();
      final sumUpAfter = statsAfter.fold<int>(0, (s, x) => s + x.bytesUp);
      expect(sumUpAfter, sumUpBefore);

      // 服务已暂停，sampleOnce 应返回但不写入（因为 isRunning=false 后
      // _tick 仍可被手动调用，但定时器已停）。
      expect(service.isRunning, false);
    });

    test('恢复后不会把旧核心计数重复入账', () async {
      final source = _ControllableSampleSource();
      final service = createServiceWithSource(source);

      // 会话 1：基线 + 增量。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      var f = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await f;

      now = DateTime(2026, 6, 27, 10, 0, 1);
      f = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      ));
      await f;
      await service.pauseAndFlush();

      final period = await periodManager.getActivePeriod();
      final stats1 = await dao.queryHourlyStats(periodId: period!.id).get();
      final sum1 = stats1.fold<int>(0, (s, x) => s + x.bytesUp);
      expect(sum1, 1000); // 仅 1000 入账

      // 模拟核心重启：generation 递增 + 总代理计数从 0 重新累加。
      // start() 递增 generation，下次 sampleOnce 触发 reconciler
      // 检测到 generation 变化，重建基线（不产生增量）。
      final genBefore = service.generation;
      service.start();
      expect(service.generation, genBefore + 1);

      // 新会话首次采样（基线重建，总代理从 0 开始）。
      now = DateTime(2026, 6, 27, 10, 0, 5);
      f = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 0, // 新会话从 0 开始
        totalProxyDown: 0,
        connections: const [],
      ));
      await f;
      await service.pauseAndFlush();

      // 验证：没有重复入账。
      final stats2 = await dao.queryHourlyStats(periodId: period.id).get();
      final sum2 = stats2.fold<int>(0, (s, x) => s + x.bytesUp);
      expect(sum2, 1000); // 仍是 1000，没有把 0 -> 1000 当成新增量
    });
  });

  group('generation 防护：过期样本丢弃', () {
    test('await sample 期间 generation 变化，丢弃样本不写入', () async {
      final source = _ControllableSampleSource();
      final service = createServiceWithSource(source);

      // 会话 1 基线。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      var f = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await f;

      // 启动会话 1 的第二次采样（会 await）。
      now = DateTime(2026, 6, 27, 10, 0, 1);
      f = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(source.pendingCount, 1);

      // 在 await 期间触发核心重启（generation 递增）。
      final genBefore = service.generation;
      // 注意：start() 同时会重置定时器，但这里我们手动调用
      // start 来模拟核心重启。
      service.start();
      expect(service.generation, genBefore + 1);

      // 完成 pending 的 collect（旧 generation 的样本）。
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 5000, // 这本是旧会话的增量
        totalProxyDown: 5000,
        connections: const [],
      ));
      await f;

      // 验证：旧 generation 的样本被丢弃。
      // 基线采样不创建 period（无增量），过期样本也不写入，
      // 因此没有活动 period、没有任何 stats。
      final period = await periodManager.getActivePeriod();
      expect(period, isNull);
      final allPeriods = await periodManager.allPeriods().get();
      expect(allPeriods, isEmpty);
    });

    test('await sample 期间 dispose，丢弃样本', () async {
      final source = _ControllableSampleSource();
      final service = createServiceWithSource(source);

      // 启动采样但不完成。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      final f = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(source.pendingCount, 1);

      // 在 await 期间 dispose（但 dispose 也要等采样完成）。
      // 这里测试：dispose 会等待在飞采样，完成后丢弃。
      final disposeFuture = service.flushAndDispose();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // 完成采样。
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 5000,
        totalProxyDown: 5000,
        connections: const [],
      ));
      await f;
      await disposeFuture;

      // 验证：样本被丢弃（因为 disposed 期间不写入）。
      final period = await periodManager.getActivePeriod();
      expect(period, isNull); // 首次基线未建立，没有创建 period
    });
  });

  group('flush 并发与 mergeBack', () {
    test('多次同时触发 flush 不重复累计', () async {
      // 使用普通 fake source（不需要延迟控制）。
      final source = _QueueSampleSource();
      final service = createServiceWithSource(source);

      // 基线。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await service.sampleOnce();

      // 增量。
      now = DateTime(2026, 6, 27, 10, 0, 1);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      ));
      await service.sampleOnce();
      expect(service.pendingBucketCount, 1);

      // 并发触发 3 次 flush。
      await Future.wait([
        service.flushOnce(),
        service.flushOnce(),
        service.flushOnce(),
      ]);

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      final sumUp = stats.fold<int>(0, (s, x) => s + x.bytesUp);
      // 仅 1000，不应被 3x。
      expect(sumUp, 1000);
    });

    test('flush 期间新增 batch 不丢失（swap-on-drain 安全）', () async {
      // 用可控的 periodManager 模拟 upsertHourlyStats 延迟，
      // 在延迟期间新增采样数据，验证 flush 完成后新数据仍在桶中。
      final slowPeriodManager = _SlowPeriodManager(dao);
      final source = _QueueSampleSource();
      final service = TrafficCollectionService(
        sampleSource: source,
        multiplierResolver: multiplierResolver,
        periodManager: slowPeriodManager,
        reconciler: reconciler,
        samplingInterval: const Duration(hours: 1),
        flushInterval: const Duration(hours: 1),
        now: () => now,
      );

      // 基线 + 增量 1。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await service.sampleOnce();

      now = DateTime(2026, 6, 27, 10, 0, 1);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      ));
      await service.sampleOnce();
      expect(service.pendingBucketCount, 1);

      // 启动 flush（会 await upsertHourlyStats，slowPeriodManager 内有延迟）。
      slowPeriodManager.delay = const Duration(milliseconds: 50);
      final flushFuture = service.flushOnce();

      // 在 flush 进行中（数据已 drain 但 DAO 写入未完成），
      // 触发新采样产生增量 2。
      now = DateTime(2026, 6, 27, 10, 0, 2);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 3000, // delta 2000
        totalProxyDown: 3000,
        connections: const [],
      ));
      await service.sampleOnce();
      expect(service.pendingBucketCount, 1); // 增量 2 在新桶中

      await flushFuture;

      // 此时桶中应仍有增量 2（2000），等待下次 flush。
      expect(service.pendingBucketCount, 1);

      // 第二次 flush 把增量 2 写入 DAO。
      slowPeriodManager.delay = Duration.zero;
      await service.flushOnce();
      expect(service.pendingBucketCount, 0);

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      final sumUp = stats.fold<int>(0, (s, x) => s + x.bytesUp);
      // 1000 + 2000 = 3000，无丢失、无重复。
      expect(sumUp, 3000);
    });
  });

  group('采样互斥：同一时刻最多一个 _tick', () {
    test('两个并发 sampleOnce 不冲突，结果一致', () async {
      final source = _ControllableSampleSource();
      final service = createServiceWithSource(source);

      // 同时发起两个 sampleOnce。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      final f1 = service.sampleOnce();
      final f2 = service.sampleOnce();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // 只有一个 collect 在排队（互斥）。
      expect(source.pendingCount, 1);
      source.complete(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await f1;
      // 第二个 sampleOnce 因为 _samplingInFlight=true 被跳过。
      await f2;

      // 验证：只有一次基线建立。
      expect(service.baselineEstablished, true);
      expect(source.pendingCount, 0);
    });
  });

  group('createNewBillingPeriod 协调入口（Stage 3.2）', () {
    test('串行完成 flush + 新周期 + generation 递增 + 旧样本不污染新周期', () async {
      final source = _QueueSampleSource();
      final service = createServiceWithSource(source);

      // 会话 1：建立基线 + 产生增量。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await service.sampleOnce();

      now = DateTime(2026, 6, 27, 10, 0, 1);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      ));
      await service.sampleOnce();
      expect(service.pendingBucketCount, 1);

      final genBefore = service.generation;
      final oldPeriod = await periodManager.getActivePeriod();
      expect(oldPeriod, isNotNull);

      // 调用 createNewBillingPeriod。
      final newPeriod = await service.createNewBillingPeriod(
        label: 'manual-test',
      );

      // 验证：新周期已创建，id 不同。
      expect(newPeriod.id, isNot(oldPeriod!.id));
      expect(newPeriod.label, 'manual-test');

      // 验证：generation 递增。
      expect(service.generation, genBefore + 1);

      // 验证：pending batch 已 flush（旧周期数据归旧周期）。
      expect(service.pendingBucketCount, 0);

      // 验证：旧周期有数据。
      final oldStats = await dao.queryHourlyStats(periodId: oldPeriod.id).get();
      expect(oldStats.fold<int>(0, (s, x) => s + x.bytesUp), 1000);

      // 验证：新周期无数据（尚未采样）。
      final newStats =
          await dao.queryHourlyStats(periodId: newPeriod.id).get();
      expect(newStats, isEmpty);
    });

    test('createNewBillingPeriod 后旧核心计数不重复入账', () async {
      final source = _QueueSampleSource();
      final service = createServiceWithSource(source);

      // 会话 1：基线 + 增量。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await service.sampleOnce();

      now = DateTime(2026, 6, 27, 10, 0, 1);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      ));
      await service.sampleOnce();

      // 创建新周期。
      final newPeriod = await service.createNewBillingPeriod();

      // 新周期首次采样（基线重建，不产生增量）。
      now = DateTime(2026, 6, 27, 10, 0, 5);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000, // 核心计数未变（核心未重启）
        totalProxyDown: 1000,
        connections: const [],
      ));
      await service.sampleOnce();
      await service.flushOnce();

      // 验证：新周期无数据（基线重建不产生增量）。
      final newStats =
          await dao.queryHourlyStats(periodId: newPeriod.id).get();
      expect(newStats, isEmpty);
    });

    test('createNewBillingPeriod 后服务恢复采样（若原本在运行）', () async {
      final source = _QueueSampleSource();
      final service = createServiceWithSource(source);
      service.start();
      expect(service.isRunning, true);

      // 基线。
      now = DateTime(2026, 6, 27, 10, 0, 0);
      source.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: const [],
      ));
      await service.sampleOnce();

      // createNewBillingPeriod 应恢复定时器。
      await service.createNewBillingPeriod();
      expect(service.isRunning, true);

      await service.pauseAndFlush();
      expect(service.isRunning, false);
    });
  });
}

/// 简单队列 fake source（无延迟控制）。
class _QueueSampleSource implements TrafficSampleSource {
  final List<TrafficSample?> _queue = [];

  void enqueue(TrafficSample? sample) => _queue.add(sample);

  @override
  Future<TrafficSample?> collect({DateTime? now}) async {
    if (_queue.isEmpty) return null;
    final sample = _queue.removeAt(0);
    if (sample == null) return null;
    return TrafficSample(
      observedAt: now ?? sample.observedAt,
      totalProxyUp: sample.totalProxyUp,
      totalProxyDown: sample.totalProxyDown,
      connections: sample.connections,
    );
  }
}

/// 包装 BillingPeriodManager，在 upsertHourlyStats 中注入可控延迟。
/// 用于测试 flush 期间新增 batch 不丢失（swap-on-drain 安全）。
class _SlowPeriodManager extends BillingPeriodManager {
  _SlowPeriodManager(super.dao);

  Duration delay = Duration.zero;

  @override
  Future<void> upsertHourlyStats(Iterable<HourlyTrafficStat> stats) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    await super.upsertHourlyStats(stats);
  }
}
