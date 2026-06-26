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

/// 可编程的采样数据源。按队列返回预设采样；队列空时返回 null。
class _FakeSampleSource implements TrafficSampleSource {
  final List<TrafficSample?> _queue = [];

  void enqueue(TrafficSample? sample) => _queue.add(sample);

  @override
  Future<TrafficSample?> collect({DateTime? now}) async {
    if (_queue.isEmpty) return null;
    final sample = _queue.removeAt(0);
    if (sample == null) return null;
    // 用调用方传入的 now 覆盖 observedAt，确保时钟可控。
    return TrafficSample(
      observedAt: now ?? sample.observedAt,
      totalProxyUp: sample.totalProxyUp,
      totalProxyDown: sample.totalProxyDown,
      connections: sample.connections,
    );
  }
}

/// 构造一条代理连接快照。
ConnectionSnapshot _conn({
  required String id,
  required int upload,
  required int download,
  String appIdentifier = 'chrome.exe',
  String nodeName = 'JP-Tokyo',
  String domain = 'example.com',
  String rule = 'DOMAIN-SUFFIX,example.com',
  List<String> chains = const ['Proxy', 'JP-Tokyo'],
  bool isProxy = true,
}) {
  return ConnectionSnapshot(
    id: id,
    upload: upload,
    download: download,
    appIdentifier: appIdentifier,
    nodeName: nodeName,
    domain: domain,
    rule: rule,
    chains: chains,
    isProxy: isProxy,
  );
}

/// 构造一次采样。
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
  late _FakeSampleSource sampleSource;
  late Reconciler reconciler;
  late DateTime now;

  setUp(() {
    db = _createInMemoryDb();
    dao = db.trafficLedgerDao;
    periodManager = BillingPeriodManager(dao);
    multiplierService = NodeMultiplierService(dao);
    multiplierResolver = CachedMultiplierResolver(multiplierService);
    sampleSource = _FakeSampleSource();
    reconciler = Reconciler(multiplierResolver: multiplierResolver);
    now = DateTime(2026, 6, 27, 10, 0, 0);
  });
  tearDown(() async => db.close());

  /// 构造一个使用可控时钟的服务。采样间隔设为极长，避免定时器干扰。
  TrafficCollectionService createService() {
    return TrafficCollectionService(
      sampleSource: sampleSource,
      multiplierResolver: multiplierResolver,
      periodManager: periodManager,
      reconciler: reconciler,
      samplingInterval: const Duration(hours: 1),
      flushInterval: const Duration(hours: 1),
      now: () => now,
    );
  }

  group('TrafficCollectionService lifecycle', () {
    test('start() increments generation and begins sampling', () {
      final service = createService();
      expect(service.isRunning, false);
      expect(service.generation, 0);
      service.start();
      expect(service.isRunning, true);
      expect(service.generation, 1);
      service.start();
      expect(service.generation, 2);
    });

    test('pause() stops sampling and flushes pending data', () async {
      final service = createService();
      service.start();

      // 首次采样建基线。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 2000,
        connections: [_conn(id: 'c1', upload: 500, download: 1000)],
      ));
      await service.sampleOnce();
      expect(service.baselineEstablished, true);
      expect(service.pendingBucketCount, 0);

      // 第二次采样产生增量。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 4000,
        connections: [_conn(id: 'c1', upload: 1000, download: 2000)],
      ));
      await service.sampleOnce();
      expect(service.pendingBucketCount, greaterThan(0));

      // pause 触发 flush。
      await service.pause();
      expect(service.isRunning, false);
      expect(service.pendingBucketCount, 0);

      // DAO 应有数据：chrome.exe 归因 + 未归因差额。
      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      expect(stats.length, 2);
      final attributed =
          stats.firstWhere((s) => s.appIdentifier == 'chrome.exe');
      expect(attributed.bytesUp, 500);
      expect(attributed.bytesDown, 1000);
      final unattributed = stats.firstWhere(
        (s) => s.appIdentifier == unattributedAppIdentifier,
      );
      expect(unattributed.bytesUp, 500);
      expect(unattributed.bytesDown, 1000);
    });

    test('flushAndDispose writes pending data and stops timers', () async {
      final service = createService();
      service.start();

      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 100,
        totalProxyDown: 100,
        connections: [],
      ));
      await service.sampleOnce();

      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 200,
        totalProxyDown: 200,
        connections: [],
      ));
      await service.sampleOnce();
      expect(service.pendingBucketCount, greaterThan(0));

      await service.flushAndDispose();
      expect(service.isRunning, false);

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      // 全部进未归因（连接列表为空）。
      expect(stats.length, 1);
      expect(stats.first.appIdentifier, unattributedAppIdentifier);
      expect(stats.first.bytesUp, 100);
      expect(stats.first.bytesDown, 100);
    });
  });

  group('Stage 3 Scenario 1-3: baseline + incremental + restart', () {
    test('first sample only establishes baseline, no delta written', () async {
      final service = createService();
      service.start();

      // 核心已累计 1GB，但采集服务首次看到。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1024 * 1024 * 1024,
        totalProxyDown: 0,
        connections: [
          _conn(id: 'c1', upload: 500 * 1024 * 1024, download: 0),
        ],
      ));
      await service.sampleOnce();
      expect(service.baselineEstablished, true);
      expect(service.pendingBucketCount, 0);

      // flush 应无数据写入。
      await service.flushOnce();

      // 首次采样只建基线：不应创建任何周期记录，也不应写入任何 stats。
      final period = await periodManager.getActivePeriod();
      expect(period, isNull);
      final allPeriods = await periodManager.allPeriods().get();
      expect(allPeriods, isEmpty);
    });

    test('normal incremental samples accumulate correctly', () async {
      final service = createService();
      service.start();

      // 基线。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 2000,
        connections: [_conn(id: 'c1', upload: 500, download: 1000)],
      ));
      await service.sampleOnce();

      // 增量 1。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1500,
        totalProxyDown: 3000,
        connections: [_conn(id: 'c1', upload: 800, download: 1500)],
      ));
      await service.sampleOnce();

      // 增量 2。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 4000,
        connections: [_conn(id: 'c1', upload: 1200, download: 2200)],
      ));
      await service.sampleOnce();

      await service.flushOnce();

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      // 应有 2 行：chrome.exe 归因 + 未归因差额。
      // 总代理 delta: up=1000, down=2000。
      // 连接 delta: up=700, down=1200。
      // 未归因: up=300, down=800。
      expect(stats.length, 2);
      final attributed = stats.firstWhere((s) => s.appIdentifier == 'chrome.exe');
      expect(attributed.bytesUp, 700);
      expect(attributed.bytesDown, 1200);
      final unattributed = stats.firstWhere(
        (s) => s.appIdentifier == unattributedAppIdentifier,
      );
      expect(unattributed.bytesUp, 300);
      expect(unattributed.bytesDown, 800);
    });

    test('core restart rebuilds baseline without false delta', () async {
      final service = createService();
      service.start();

      // 基线。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 2000,
        connections: [_conn(id: 'c1', upload: 500, download: 1000)],
      ));
      await service.sampleOnce();

      // 增量。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 4000,
        connections: [_conn(id: 'c1', upload: 1000, download: 2000)],
      ));
      await service.sampleOnce();

      // 模拟核心重启：start() 递增 generation。
      service.start();
      expect(service.generation, 2);

      // 重启后核心计数器归零（新会话）。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 100,
        totalProxyDown: 200,
        connections: [_conn(id: 'c1', upload: 50, download: 100)],
      ));
      await service.sampleOnce();

      // flush 后只有重启前的增量，没有重启后的虚假增量。
      await service.flushOnce();

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      final totalUp = stats.fold<int>(0, (s, r) => s + r.bytesUp);
      final totalDown = stats.fold<int>(0, (s, r) => s + r.bytesDown);
      // 重启前增量: up=500, down=1000（连接） + up=500, down=1000（未归因）。
      // 重启后: 仅建基线，无增量。
      expect(totalUp, 1000);
      expect(totalDown, 2000);
    });
  });

  group('Stage 3 Scenario 6: DIRECT not counted', () {
    test('DIRECT connections excluded from proxy total', () async {
      final service = createService();
      service.start();

      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(
            id: 'direct1',
            upload: 500,
            download: 500,
            chains: const ['DIRECT'],
            isProxy: false,
          ),
        ],
      ));
      await service.sampleOnce();

      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 2000,
        connections: [
          _conn(
            id: 'direct1',
            upload: 1000,
            download: 1000,
            chains: const ['DIRECT'],
            isProxy: false,
          ),
        ],
      ));
      await service.sampleOnce();
      await service.flushOnce();

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      // DIRECT 连接不计入归因；总代理增量 1000+1000 全部进未归因。
      expect(stats.length, 1);
      expect(stats.first.appIdentifier, unattributedAppIdentifier);
      expect(stats.first.bytesUp, 1000);
      expect(stats.first.bytesDown, 1000);
    });
  });

  group('Stage 3 Scenario 7: proxy host process excluded', () {
    test('FlClash.exe not in normal app ranking', () async {
      final service = createService();
      service.start();

      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(
            id: 'flc1',
            upload: 500,
            download: 500,
            appIdentifier: 'FlClash.exe',
          ),
        ],
      ));
      await service.sampleOnce();

      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 2000,
        connections: [
          _conn(
            id: 'flc1',
            upload: 1000,
            download: 1000,
            appIdentifier: 'FlClash.exe',
          ),
        ],
      ));
      await service.sampleOnce();
      await service.flushOnce();

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      // FlClash.exe 不作为普通应用排行；总代理增量全部进未归因。
      expect(stats.length, 1);
      expect(stats.first.appIdentifier, unattributedAppIdentifier);
      expect(stats.first.bytesUp, 1000);
      expect(stats.first.bytesDown, 1000);
    });
  });

  group('Stage 3 Scenario 12-13: period boundary', () {
    test('samples before/after billingCycleDay boundary go to correct period',
        () async {
      // 设置 billingCycleDay=27, autoCycleEnabled=true。
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 27,
      ));
      // 手动创建旧周期 startAt=2026-05-27。
      final oldPeriod = await dao.startNewPeriod(startAt: DateTime(2026, 5, 27));

      final service = createService();
      service.start();

      // 基线：边界前 23:58:00，total=0。
      now = DateTime(2026, 6, 26, 23, 58, 0);
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: [],
      ));
      await service.sampleOnce();
      expect(service.baselineEstablished, true);

      // 边界前增量：23:59:00，total=1000 → delta 1000 → 旧周期（hourStart=23）。
      now = DateTime(2026, 6, 26, 23, 59, 0);
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [],
      ));
      await service.sampleOnce();

      // 边界后增量：00:00:30，total=2000 → delta 1000 → 新周期（hourStart=0）。
      now = DateTime(2026, 6, 27, 0, 0, 30);
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 2000,
        connections: [],
      ));
      await service.sampleOnce();

      // flush 发生在边界后（验证 flush 时刻不影响样本归属）。
      now = DateTime(2026, 6, 27, 0, 1, 0);
      await service.flushOnce();

      // 旧周期应有 1 行（边界前增量 1000，hourStart=2026-06-26 23:00）。
      final oldStats = await dao.queryHourlyStats(periodId: oldPeriod.id).get();
      expect(oldStats.length, 1);
      expect(oldStats.first.bytesUp, 1000);
      expect(oldStats.first.bytesDown, 1000);
      expect(oldStats.first.hourStart, DateTime(2026, 6, 26, 23));

      // 新周期应有 1 行（边界后增量 1000，hourStart=2026-06-27 00:00）。
      final newPeriod = await periodManager.getActivePeriod();
      expect(newPeriod!.id, isNot(oldPeriod.id));
      final newStats =
          await dao.queryHourlyStats(periodId: newPeriod.id).get();
      expect(newStats.length, 1);
      expect(newStats.first.bytesUp, 1000);
      expect(newStats.first.bytesDown, 1000);
      expect(newStats.first.hourStart, DateTime(2026, 6, 27, 0));
    });
  });

  group('Stage 3 Scenario 14: non-integer multiplier precision', () {
    test('1.5x multiplier with many small deltas no underestimation', () async {
      // 设置节点倍率。
      await multiplierService.setManualMultiplier('HK-1.5x', 1.5);
      // 刷新缓存。
      await multiplierResolver.refreshFor(['HK-1.5x']);

      final service = createService();
      service.start();

      // 基线。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: [
          _conn(id: 'c1', upload: 0, download: 0, nodeName: 'HK-1.5x'),
        ],
      ));
      await service.sampleOnce();

      // 1000 次 1 byte 增量。
      for (var i = 1; i <= 1000; i++) {
        now = now.add(const Duration(seconds: 1));
        sampleSource.enqueue(_sample(
          observedAt: now,
          totalProxyUp: i,
          totalProxyDown: 0,
          connections: [
            _conn(id: 'c1', upload: i, download: 0, nodeName: 'HK-1.5x'),
          ],
        ));
        await service.sampleOnce();
      }

      await service.flushOnce();

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      final attributed = stats.firstWhere((s) => s.appIdentifier == 'chrome.exe');
      // 1000 bytes * 1.5 = 1500 bytes。
      expect(attributed.bytesUp, 1000);
      expect(attributed.estimatedBilledBytesUp, 1500);
      expect(attributed.billedRemainderUp, 0);
    });
  });

  group('Stage 3 Scenario 15: missing multiplier', () {
    test('unknown node: actual bytes counted, billed not faked as 1x', () async {
      final service = createService();
      service.start();

      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 0,
        totalProxyDown: 0,
        connections: [
          _conn(id: 'c1', upload: 0, download: 0, nodeName: 'UnknownNode'),
        ],
      ));
      await service.sampleOnce();

      // 刷新缓存（UnknownNode 无 DB 记录、无倍率模式 → null）。
      // 注意：sampleOnce 内部会自动调用 refreshFor。

      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 2000,
        connections: [
          _conn(id: 'c1', upload: 1000, download: 2000, nodeName: 'UnknownNode'),
        ],
      ));
      await service.sampleOnce();
      await service.flushOnce();

      final period = await periodManager.getActivePeriod();
      final stats = await dao.queryHourlyStats(periodId: period!.id).get();
      final attributed = stats.firstWhere((s) =>
          s.appIdentifier == 'chrome.exe' && s.nodeName == 'UnknownNode');
      // 实际流量计入。
      expect(attributed.bytesUp, 1000);
      expect(attributed.bytesDown, 2000);
      // 预计扣量不伪造为 1×：哨兵 -1。
      expect(attributed.billedRemainderUp, -1);
      expect(attributed.billedRemainderDown, -1);
      expect(attributed.estimatedBilledBytesUp, 0);
      expect(attributed.estimatedBilledBytesDown, 0);
    });
  });

  group('Stage 3 Scenario 10-11: core stop/restart same period', () {
    test('pause then start continues same period without double counting',
        () async {
      final service = createService();
      service.start();

      // 基线 + 增量。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [],
      ));
      await service.sampleOnce();

      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 2000,
        totalProxyDown: 2000,
        connections: [],
      ));
      await service.sampleOnce();

      // 暂停（核心停止）。
      await service.pause();
      final periodAfterPause = await periodManager.getActivePeriod();

      // 核心再次启动。
      service.start();
      expect(service.generation, 2);

      // 新会话基线（计数器从 0 开始）。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 500,
        totalProxyDown: 500,
        connections: [],
      ));
      await service.sampleOnce();

      // 新增量。
      now = now.add(const Duration(seconds: 1));
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1500,
        totalProxyDown: 1500,
        connections: [],
      ));
      await service.sampleOnce();

      await service.flushOnce();

      // 仍为同一活动周期。
      final periodAfterResume = await periodManager.getActivePeriod();
      expect(periodAfterResume!.id, periodAfterPause!.id);

      final stats =
          await dao.queryHourlyStats(periodId: periodAfterResume.id).get();
      // 暂停前增量: 1000+1000。
      // 重启后增量: 1000+1000。
      // 总计: 2000+2000，无重复统计。
      final totalUp = stats.fold<int>(0, (s, r) => s + r.bytesUp);
      final totalDown = stats.fold<int>(0, (s, r) => s + r.bytesDown);
      expect(totalUp, 2000);
      expect(totalDown, 2000);
    });
  });

  group('Sample source returning null', () {
    test('null sample does not break service or change state', () async {
      final service = createService();
      service.start();

      sampleSource.enqueue(null);
      await service.sampleOnce();
      expect(service.baselineEstablished, false);
      expect(service.pendingBucketCount, 0);

      // 后续正常采样仍可工作。
      sampleSource.enqueue(_sample(
        observedAt: now,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [],
      ));
      await service.sampleOnce();
      expect(service.baselineEstablished, true);
    });
  });
}
