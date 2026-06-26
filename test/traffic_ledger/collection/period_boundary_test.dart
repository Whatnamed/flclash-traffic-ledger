import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/collection/hourly_bucket.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';
import 'package:test/test.dart';

Database _createInMemoryDb() => Database(NativeDatabase.memory());

AttributedDelta _delta({
  String appIdentifier = 'chrome.exe',
  String nodeName = 'JP-Tokyo',
  String domain = 'example.com',
  String rule = 'DOMAIN',
  int deltaUp = 0,
  int deltaDown = 0,
  double effectiveMultiplier = 1.0,
}) {
  return AttributedDelta(
    appIdentifier: appIdentifier,
    nodeName: nodeName,
    domain: domain,
    rule: rule,
    deltaUp: deltaUp,
    deltaDown: deltaDown,
    effectiveMultiplier: effectiveMultiplier,
    estimatedBilledDeltaUp: 0,
    estimatedBilledDeltaDown: 0,
    billedRemainderDeltaUp: 0,
    billedRemainderDeltaDown: 0,
  );
}

void main() {
  group('Scenario 12: 采样点位于 billingCycleDay 边界前后数据落在正确周期', () {
    late Database db;
    late TrafficLedgerDao dao;
    late BillingPeriodManager manager;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
      manager = BillingPeriodManager(dao);
    });
    tearDown(() async => db.close());

    test('sample at 23:59:59 -> old period; sample at 00:00:01 -> new period', () async {
      // 设置：billingCycleDay=27, autoCycleEnabled=true
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 27,
      ));

      // 模拟旧周期已运行：手动创建一个 startAt=2026-05-27 的活动周期
      final oldPeriod = await dao.startNewPeriod(startAt: DateTime(2026, 5, 27));
      expect(oldPeriod.endAt, isNull);

      // 23:59:59 边界前采样
      final beforeBoundary = DateTime(2026, 6, 26, 23, 59, 59);
      // 此时调用 ensureActivePeriod 应返回旧周期，不切换
      final periodBefore = await manager.ensureActivePeriod(now: beforeBoundary);
      expect(periodBefore.id, oldPeriod.id);

      final batch = FlushBatch();
      batch.add(
        periodId: periodBefore.id,
        observedAt: beforeBoundary,
        delta: _delta(deltaUp: 100, deltaDown: 100, effectiveMultiplier: 1.0),
      );

      // 00:00:01 边界后采样
      final afterBoundary = DateTime(2026, 6, 27, 0, 0, 1);
      // 此时调用 ensureActivePeriod 应触发自动切换
      final periodAfter = await manager.ensureActivePeriod(now: afterBoundary);
      expect(periodAfter.id, isNot(oldPeriod.id));
      expect(periodAfter.startAt, DateTime(2026, 6, 27).millisecondsSinceEpoch);

      batch.add(
        periodId: periodAfter.id,
        observedAt: afterBoundary,
        delta: _delta(deltaUp: 200, deltaDown: 200, effectiveMultiplier: 1.0),
      );

      // Flush
      final flushAt = DateTime(2026, 6, 27, 0, 0, 5);
      final stats = batch.drain(updatedAt: flushAt);
      await dao.upsertHourlyStats(stats);

      // 旧周期应有 1 行，hourStart=2026-06-26 23:00
      final oldStats = await dao.queryHourlyStats(periodId: oldPeriod.id).get();
      expect(oldStats.length, 1);
      expect(oldStats.first.hourStart, DateTime(2026, 6, 26, 23));
      expect(oldStats.first.bytesUp, 100);

      // 新周期应有 1 行，hourStart=2026-06-27 00:00
      final newStats = await dao.queryHourlyStats(periodId: periodAfter.id).get();
      expect(newStats.length, 1);
      expect(newStats.first.hourStart, DateTime(2026, 6, 27, 0));
      expect(newStats.first.bytesUp, 200);
    });
  });

  group('Scenario 13: flush 发生在周期边界之后不能把边界前样本写到新周期', () {
    late Database db;
    late TrafficLedgerDao dao;
    late BillingPeriodManager manager;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
      manager = BillingPeriodManager(dao);
    });
    tearDown(() async => db.close());

    test('sample observed before boundary, flush after boundary - stays in old period', () async {
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 27,
      ));
      final oldPeriod = await dao.startNewPeriod(startAt: DateTime(2026, 5, 27));

      // 23:59:59 采样
      final beforeBoundary = DateTime(2026, 6, 26, 23, 59, 59);
      final periodBefore = await manager.ensureActivePeriod(now: beforeBoundary);
      expect(periodBefore.id, oldPeriod.id);

      final batch = FlushBatch();
      batch.add(
        periodId: periodBefore.id,
        observedAt: beforeBoundary,
        delta: _delta(deltaUp: 500, deltaDown: 500, effectiveMultiplier: 1.0),
      );

      // 此时 batch 中有一个待 flush 的样本，periodId=oldPeriod.id
      // 但还没 flush

      // 时间推进到 00:00:30，过了边界
      final flushTime = DateTime(2026, 6, 27, 0, 0, 30);
      // 在 flush 之前，若调用 ensureActivePeriod(now=flushTime)，会触发切换
      final periodAtFlush = await manager.ensureActivePeriod(now: flushTime);
      expect(periodAtFlush.id, isNot(oldPeriod.id)); // 已切换到新周期
      expect(periodAtFlush.startAt, DateTime(2026, 6, 27).millisecondsSinceEpoch);

      // 关键点：此时 flush，batch 中已有的样本 periodId 仍是 oldPeriod.id
      // （periodId 在 add() 时已捕获，drain() 不重新查询）
      final stats = batch.drain(updatedAt: flushTime);
      await dao.upsertHourlyStats(stats);

      // 旧周期应有 1 行（边界前样本）
      final oldStats = await dao.queryHourlyStats(periodId: oldPeriod.id).get();
      expect(oldStats.length, 1);
      expect(oldStats.first.hourStart, DateTime(2026, 6, 26, 23));
      expect(oldStats.first.bytesUp, 500);

      // 新周期应为空
      final newStats = await dao.queryHourlyStats(periodId: periodAtFlush.id).get();
      expect(newStats, isEmpty);

      // 验证 batch 已清空
      expect(batch.isEmpty, isTrue);
    });

    test('multiple samples across boundary - each keeps its own periodId', () async {
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 27,
      ));
      final oldPeriod = await dao.startNewPeriod(startAt: DateTime(2026, 5, 27));

      final batch = FlushBatch();

      // 边界前多个采样点（23:00, 23:30, 23:59:59）
      for (final t in [
        DateTime(2026, 6, 26, 23, 0, 0),
        DateTime(2026, 6, 26, 23, 30, 0),
        DateTime(2026, 6, 26, 23, 59, 59),
      ]) {
        final p = await manager.ensureActivePeriod(now: t);
        batch.add(
          periodId: p.id,
          observedAt: t,
          delta: _delta(deltaUp: 100, deltaDown: 100, effectiveMultiplier: 1.0),
        );
      }

      // 边界后多个采样点（00:00:01, 00:30, 01:00）
      final postBoundaryTimes = [
        DateTime(2026, 6, 27, 0, 0, 1),
        DateTime(2026, 6, 27, 0, 30, 0),
        DateTime(2026, 6, 27, 1, 0, 0),
      ];
      int? newPeriodId;
      for (final t in postBoundaryTimes) {
        final p = await manager.ensureActivePeriod(now: t);
        newPeriodId = p.id;
        batch.add(
          periodId: p.id,
          observedAt: t,
          delta: _delta(deltaUp: 200, deltaDown: 200, effectiveMultiplier: 1.0),
        );
      }

      // Flush at 01:30
      await dao.upsertHourlyStats(batch.drain(updatedAt: DateTime(2026, 6, 27, 1, 30)));

      // 旧周期：3 个采样点都在 23:00 hour，聚合为 1 行，bytes=300
      final oldStats = await dao.queryHourlyStats(periodId: oldPeriod.id).get();
      expect(oldStats.length, 1);
      expect(oldStats.first.hourStart, DateTime(2026, 6, 26, 23));
      expect(oldStats.first.bytesUp, 300);

      // 新周期：3 个采样点分布在 00:00 和 01:00 两个 hour
      // 00:00 hour 有 2 个采样（00:00:01, 00:30）-> bytes=400
      // 01:00 hour 有 1 个采样 -> bytes=200
      final newStats = await dao.queryHourlyStats(periodId: newPeriodId!).get();
      expect(newStats.length, 2);
      final hour00 = newStats.firstWhere(
        (s) => s.hourStart == DateTime(2026, 6, 27, 0),
      );
      final hour01 = newStats.firstWhere(
        (s) => s.hourStart == DateTime(2026, 6, 27, 1),
      );
      expect(hour00.bytesUp, 400);
      expect(hour01.bytesUp, 200);
    });
  });

  group('Scenario 14: 非整数倍率多次小增量 via FlushBatch + DAO upsert', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('1.5x 1000 small increments persisted correctly via upsert', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);
      final batch = FlushBatch();

      // 模拟 1000 次小增量，每次 1 byte @ 1.5x，全部落在同一小时内
      for (var i = 0; i < 1000; i++) {
        batch.add(
          periodId: p.id,
          observedAt: hour,
          delta: _delta(deltaUp: 1, deltaDown: 0, effectiveMultiplier: 1.5),
        );
      }

      await dao.upsertHourlyStats(batch.drain(updatedAt: hour.add(const Duration(minutes: 30))));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 1000);
      // 1000 * 1.5 = 1500 (毫字节余数方案，无低估)
      expect(stats.first.estimatedBilledBytesUp, 1500);
      expect(stats.first.billedRemainderUp, 0);
    });

    test('0.1x 10000 small increments persisted correctly', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);
      final batch = FlushBatch();

      // 所有样本都落在同一小时内（observedAt = hour），
      // 验证毫字节余数方案不会因反复截断低估。
      for (var i = 0; i < 10000; i++) {
        batch.add(
          periodId: p.id,
          observedAt: hour,
          delta: _delta(deltaUp: 1, deltaDown: 0, effectiveMultiplier: 0.1),
        );
      }

      await dao.upsertHourlyStats(batch.drain(updatedAt: hour.add(const Duration(minutes: 30))));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 10000);
      // 10000 * 0.1 = 1000
      // 若用浮点截断: (1 * 0.1).floor() = 0, 累加 10000 次 = 0 (完全低估)
      // 毫字节余数方案应严格等于 1000
      expect(stats.first.estimatedBilledBytesUp, 1000);
      expect(stats.first.billedRemainderUp, 0);
    });

    test('multi-flush accumulates remainder correctly across flushes', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);

      // 第一次 flush: 500 个 1 byte @ 1.5x = 750 bytes
      var batch = FlushBatch();
      for (var i = 0; i < 500; i++) {
        batch.add(
          periodId: p.id,
          observedAt: hour,
          delta: _delta(deltaUp: 1, deltaDown: 0, effectiveMultiplier: 1.5),
        );
      }
      await dao.upsertHourlyStats(batch.drain(updatedAt: hour));

      // 第二次 flush: 再 500 个 1 byte @ 1.5x = 750 bytes
      batch = FlushBatch();
      for (var i = 0; i < 500; i++) {
        batch.add(
          periodId: p.id,
          observedAt: hour,
          delta: _delta(deltaUp: 1, deltaDown: 0, effectiveMultiplier: 1.5),
        );
      }
      await dao.upsertHourlyStats(batch.drain(updatedAt: hour));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 1000);
      // 跨 flush 累加，最终仍应为 1500
      expect(stats.first.estimatedBilledBytesUp, 1500);
      expect(stats.first.billedRemainderUp, 0);
    });
  });

  group('Scenario 15: 节点缺失时实际流量计入，扣量不伪造 1× (DAO 层)', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('unattributed delta persists with sentinel remainder', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);
      final batch = FlushBatch();

      // 未归因增量
      batch.add(
        periodId: p.id,
        observedAt: hour,
        delta: const AttributedDelta(
          appIdentifier: unattributedAppIdentifier,
          nodeName: unknownDimensionValue,
          domain: unknownDimensionValue,
          rule: unknownDimensionValue,
          deltaUp: 500,
          deltaDown: 500,
          effectiveMultiplier: 0,
          estimatedBilledDeltaUp: 0,
          estimatedBilledDeltaDown: 0,
          billedRemainderDeltaUp: unbilledSentinel,
          billedRemainderDeltaDown: unbilledSentinel,
        ),
      );

      await dao.upsertHourlyStats(batch.drain(updatedAt: hour));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.appIdentifier, unattributedAppIdentifier);
      expect(stats.first.bytesUp, 500);
      expect(stats.first.bytesDown, 500);
      expect(stats.first.estimatedBilledBytesUp, 0);
      expect(stats.first.estimatedBilledBytesDown, 0);
      expect(stats.first.billedRemainderUp, unbilledSentinel);
      expect(stats.first.billedRemainderDown, unbilledSentinel);
      expect(stats.first.isUnbilled, isTrue);
      expect(stats.first.isUnattributed, isTrue);
    });

    test('mix of attributed and unattributed in same hour stays separate', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);
      final batch = FlushBatch();

      // 已归因（chrome.exe, JP-Tokyo, 1.0x）
      batch.add(
        periodId: p.id,
        observedAt: hour,
        delta: _delta(
          appIdentifier: 'chrome.exe',
          nodeName: 'JP-Tokyo',
          deltaUp: 300,
          deltaDown: 300,
          effectiveMultiplier: 1.0,
        ),
      );
      // 未归因
      batch.add(
        periodId: p.id,
        observedAt: hour,
        delta: const AttributedDelta(
          appIdentifier: unattributedAppIdentifier,
          nodeName: unknownDimensionValue,
          domain: unknownDimensionValue,
          rule: unknownDimensionValue,
          deltaUp: 200,
          deltaDown: 200,
          effectiveMultiplier: 0,
          estimatedBilledDeltaUp: 0,
          estimatedBilledDeltaDown: 0,
          billedRemainderDeltaUp: unbilledSentinel,
          billedRemainderDeltaDown: unbilledSentinel,
        ),
      );

      await dao.upsertHourlyStats(batch.drain(updatedAt: hour));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 2);

      final attributed = stats.firstWhere((s) => s.appIdentifier == 'chrome.exe');
      expect(attributed.bytesUp, 300);
      expect(attributed.estimatedBilledBytesUp, 300);
      expect(attributed.billedRemainderUp, 0);
      expect(attributed.isUnbilled, isFalse);

      final unattributed = stats.firstWhere((s) => s.isUnattributed);
      expect(unattributed.bytesUp, 200);
      expect(unattributed.estimatedBilledBytesUp, 0);
      expect(unattributed.billedRemainderUp, unbilledSentinel);
      expect(unattributed.isUnbilled, isTrue);
    });
  });

  group('Scenario 16: 同一小时内倍率变更 DAO 持久化保持入账时倍率', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('1GB@2x + 1GB@3x persists as 2GB actual + 5GB billed', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);
      const gb = 1024 * 1024 * 1024;

      final batch = FlushBatch();
      batch.add(
        periodId: p.id,
        observedAt: hour,
        delta: _delta(
          deltaUp: gb,
          deltaDown: 0,
          effectiveMultiplier: 2.0,
        ),
      );
      batch.add(
        periodId: p.id,
        observedAt: hour,
        delta: _delta(
          deltaUp: gb,
          deltaDown: 0,
          effectiveMultiplier: 3.0,
        ),
      );

      await dao.upsertHourlyStats(batch.drain(updatedAt: hour));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 2 * gb);
      expect(stats.first.estimatedBilledBytesUp, 5 * gb);
      // multiplier 保留首次值 2.0（展示用途）
      expect(stats.first.multiplier, 2.0);
      // isUnbilled 应为 false（两笔都可估算）
      expect(stats.first.isUnbilled, isFalse);
    });

    test('after multiplier change, modifying node record does not rewrite history', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = DateTime(2026, 6, 27, 10);
      const gb = 1024 * 1024 * 1024;

      // 先用 2x 写入 1GB
      final batch = FlushBatch();
      batch.add(
        periodId: p.id,
        observedAt: hour,
        delta: _delta(
          deltaUp: gb,
          deltaDown: 0,
          effectiveMultiplier: 2.0,
        ),
      );
      await dao.upsertHourlyStats(batch.drain(updatedAt: hour));

      // 用户修改节点倍率为 3x（DAO 层模拟）
      // 注意：修改节点倍率记录不会回写已有的 hourly stats
      await dao.upsertNodeMultiplier(nodeName: 'JP-Tokyo', parsedMultiplier: 3.0);

      // 再用 3x 写入 1GB
      final batch2 = FlushBatch();
      batch2.add(
        periodId: p.id,
        observedAt: hour,
        delta: _delta(
          deltaUp: gb,
          deltaDown: 0,
          effectiveMultiplier: 3.0,
        ),
      );
      await dao.upsertHourlyStats(batch2.drain(updatedAt: hour));

      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      // 实际流量 = 2GB
      expect(stats.first.bytesUp, 2 * gb);
      // 预计扣量 = 2GB + 3GB = 5GB
      // 不应是 2*2=4GB（按当前倍率重算）也不应是 2*3=6GB
      expect(stats.first.estimatedBilledBytesUp, 5 * gb);
      expect(stats.first.billedBytes, 5 * gb);
      expect(stats.first.billedBytes, isNot(4 * gb));
      expect(stats.first.billedBytes, isNot(6 * gb));
    });
  });
}
