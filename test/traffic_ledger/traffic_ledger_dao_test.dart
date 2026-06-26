import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_cycle_calculator.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/node_multiplier_service.dart';
import 'package:test/test.dart';

/// 创建内存数据库用于测试。每个测试独立实例，避免相互干扰。
Database _createInMemoryDb() {
  return Database(NativeDatabase.memory());
}

DateTime _hourStart(DateTime t) =>
    DateTime(t.year, t.month, t.day, t.hour);

/// 1 GB in bytes.
const int _gb = 1024 * 1024 * 1024;

void main() {
  group('TrafficLedgerDao - billing periods', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('getActivePeriod returns null when empty', () async {
      expect(await dao.getActivePeriod(), isNull);
    });

    test('startNewPeriod creates active period and no old period closed', () async {
      final now = DateTime(2026, 6, 25, 10, 0);
      final p = await dao.startNewPeriod(startAt: now);
      expect(p.endAt, isNull);
      expect(p.startAt, now.millisecondsSinceEpoch);
      expect(p.id, greaterThan(0));
      final active = await dao.getActivePeriod();
      expect(active?.id, p.id);
    });

    test('startNewPeriod closes previous active period', () async {
      final t1 = DateTime(2026, 6, 1, 10, 0);
      final t2 = DateTime(2026, 6, 25, 10, 0);
      final p1 = await dao.startNewPeriod(startAt: t1);
      final p2 = await dao.startNewPeriod(startAt: t2);
      // p1 should now be closed, p2 active.
      final closed = await (db.select(db.trafficBillingPeriods)
            ..where((t) => t.id.equals(p1.id)))
          .getSingle();
      expect(closed.endAt, t2.millisecondsSinceEpoch);
      expect(p2.endAt, isNull);
      final active = await dao.getActivePeriod();
      expect(active?.id, p2.id);
    });

    test('allPeriods ordered by startAt desc', () async {
      await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      await dao.startNewPeriod(startAt: DateTime(2026, 5, 1));
      await dao.startNewPeriod(startAt: DateTime(2026, 6, 25));
      final all = await dao.allPeriods().get();
      expect(all.length, 3);
      expect(all[0].startAt, greaterThan(all[1].startAt));
      expect(all[1].startAt, greaterThan(all[2].startAt));
    });

    test('maybeAutoCycleSwitch does nothing when autoCycle disabled', () async {
      final t1 = DateTime(2026, 6, 1);
      await dao.startNewPeriod(startAt: t1);
      // settings 默认 autoCycleEnabled=false
      final result = await dao.maybeAutoCycleSwitch(now: DateTime(2026, 7, 15));
      expect(result, isNull);
      final all = await dao.allPeriods().get();
      expect(all.length, 1);
    });

    test('maybeAutoCycleSwitch creates new period when crossed refresh day', () async {
      final t1 = DateTime(2026, 6, 1);
      final p = await dao.startNewPeriod(startAt: t1);
      // 开启自动周期，刷新日=25
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      final newPeriod = await dao.maybeAutoCycleSwitch(now: DateTime(2026, 6, 26));
      expect(newPeriod, isNotNull);
      expect(newPeriod!.id, isNot(p.id));
      // 新周期起始为 6-25 00:00（因为旧周期 6-1 起，下一刷新边界是 6-25）
      final start = DateTime.fromMillisecondsSinceEpoch(newPeriod.startAt);
      expect(start, DateTime(2026, 6, 25));
      // 旧周期已结束
      final old = await (db.select(db.trafficBillingPeriods)
            ..where((t) => t.id.equals(p.id)))
          .getSingle();
      expect(old.endAt, isNotNull);
    });

    test('maybeAutoCycleSwitch no-op when before refresh boundary', () async {
      await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 6-10 还在 6-1 ~ 6-25 周期内
      final result = await dao.maybeAutoCycleSwitch(now: DateTime(2026, 6, 10));
      expect(result, isNull);
    });

    test('updatePeriod updates label only', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      await dao.updatePeriod(p.id, label: 'June');
      final updated = await (db.select(db.trafficBillingPeriods)
            ..where((t) => t.id.equals(p.id)))
          .getSingle();
      expect(updated.label, 'June');
    });

    test('clearTrafficHistory deletes periods+stats but preserves multipliers+settings', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: 'example.com',
          rule: 'DOMAIN',
          bytesUp: 100,
          bytesDown: 200,
          multiplier: 1.0,
          updatedAt: hour,
        ),
      ]);
      await dao.upsertNodeMultiplier(
        nodeName: 'node1',
        parsedMultiplier: 2.0,
      );
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      await dao.clearTrafficHistory();
      // 周期和统计被删
      expect(await dao.getActivePeriod(), isNull);
      expect(await dao.allPeriods().get(), isEmpty);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats, isEmpty);
      // 节点倍率保留
      final mult = await dao.getNodeMultiplier('node1');
      expect(mult, isNotNull);
      expect(mult?.parsedMultiplier, 2.0);
      // 账本设置保留
      final settings = await dao.getSettings();
      expect(settings.autoCycleEnabled, isTrue);
      expect(settings.billingCycleDay, 25);
    });

    test('resetLedgerSettings deletes multipliers+settings but preserves periods+stats', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 100,
          bytesDown: 200,
          multiplier: 1.0,
          updatedAt: hour,
        ),
      ]);
      await dao.upsertNodeMultiplier(
        nodeName: 'node1',
        parsedMultiplier: 2.0,
        manualMultiplier: 3.0,
      );
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      await dao.resetLedgerSettings();
      // 周期和统计保留
      final active = await dao.getActivePeriod();
      expect(active, isNotNull);
      expect(active?.id, p.id);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 100);
      // 节点倍率被删
      expect(await dao.getNodeMultiplier('node1'), isNull);
      // 账本设置恢复默认
      final settings = await dao.getSettings();
      expect(settings.autoCycleEnabled, isFalse);
      expect(settings.billingCycleDay, 1);
    });
  });

  group('TrafficLedgerDao - hourly stats', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('upsertHourlyStats inserts new row', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 100,
          bytesDown: 200,
          multiplier: 2.0,
          estimatedBilledBytesUp: 200,
          estimatedBilledBytesDown: 400,
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 100);
      expect(stats.first.bytesDown, 200);
      expect(stats.first.multiplier, 2.0);
      expect(stats.first.estimatedBilledBytesUp, 200);
      expect(stats.first.estimatedBilledBytesDown, 400);
    });

    test('upsertHourlyStats accumulates bytes and estimated on same key', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 100,
          bytesDown: 200,
          multiplier: 2.0,
          estimatedBilledBytesUp: 200,
          estimatedBilledBytesDown: 400,
          updatedAt: hour,
        ),
      ]);
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 50,
          bytesDown: 70,
          multiplier: 3.0, // 倍率变化
          estimatedBilledBytesUp: 150, // 50 * 3.0
          estimatedBilledBytesDown: 210, // 70 * 3.0
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 150);
      expect(stats.first.bytesDown, 270);
      // multiplier 保留首次值（展示用途）
      expect(stats.first.multiplier, 2.0);
      // estimated 累加
      expect(stats.first.estimatedBilledBytesUp, 350); // 200 + 150
      expect(stats.first.estimatedBilledBytesDown, 610); // 400 + 210
      // billedBytes 来自 estimated，不是 totalBytes * multiplier
      expect(stats.first.billedBytes, 960); // 350 + 610
      expect(stats.first.billedBytes, isNot(stats.first.totalBytes * stats.first.multiplier));
    });

    test('multiplier preserved on accumulation (history immutability)', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 100,
          bytesDown: 0,
          multiplier: 2.0,
          estimatedBilledBytesUp: 200,
          updatedAt: hour,
        ),
      ]);
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 50,
          bytesDown: 0,
          multiplier: 3.0,
          estimatedBilledBytesUp: 150,
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.multiplier, 2.0); // preserved, not 3.0
      expect(stats.first.bytesUp, 150);
      expect(stats.first.estimatedBilledBytesUp, 350); // 200 + 150
    });

    test('same-hour multiplier change: 1GB@2x + 1GB@3x = 2GB actual, 5GB billed', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      // 第一次 1 GB 上行，倍率 2x
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: _gb,
          bytesDown: 0,
          multiplier: 2.0,
          estimatedBilledBytesUp: (_gb * 2).round(), // 2 GB
          updatedAt: hour,
        ),
      ]);
      // 用户修改节点倍率为 3x
      // 第二次 1 GB 上行，倍率 3x
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: _gb,
          bytesDown: 0,
          multiplier: 3.0,
          estimatedBilledBytesUp: (_gb * 3).round(), // 3 GB
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      // 实际流量 = 2 GB
      expect(stats.first.bytesUp, 2 * _gb);
      expect(stats.first.totalBytes, 2 * _gb);
      // 预计扣量 = 5 GB（2 + 3），不是 4（2*2）也不是 6（2*3）
      expect(stats.first.estimatedBilledBytesUp, 5 * _gb);
      expect(stats.first.billedBytes, 5 * _gb);
      expect(stats.first.billedBytes, isNot(4 * _gb));
      expect(stats.first.billedBytes, isNot(6 * _gb));

      // 后续修改节点倍率不得改写已入账预计扣量
      await dao.upsertNodeMultiplier(
        nodeName: 'node1',
        parsedMultiplier: 1.0,
        manualMultiplier: 10.0,
      );
      final statsAfter = await dao.queryHourlyStats(periodId: p.id).get();
      expect(statsAfter.first.billedBytes, 5 * _gb); // 不变
    });

    test('different dimensions produce separate rows', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 100,
          bytesDown: 0,
          multiplier: 1.0,
          updatedAt: hour,
        ),
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app2',
          nodeName: 'node1',
          domain: '',
          rule: '',
          bytesUp: 50,
          bytesDown: 0,
          multiplier: 1.0,
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 2);
    });

    test('queryHourlyStats respects time range', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final h1 = _hourStart(DateTime(2026, 6, 25, 10));
      final h2 = _hourStart(DateTime(2026, 6, 25, 11));
      final h3 = _hourStart(DateTime(2026, 6, 25, 12));
      for (final h in [h1, h2, h3]) {
        await dao.upsertHourlyStats([
          HourlyTrafficStat(
            periodId: p.id,
            hourStart: h,
            appIdentifier: 'app1',
            nodeName: '',
            domain: '',
            rule: '',
            bytesUp: 10,
            bytesDown: 0,
            multiplier: 1.0,
            updatedAt: h,
          ),
        ]);
      }
      // [h2, h3) should only include h2.
      final stats = await dao
          .queryHourlyStats(periodId: p.id, from: h2, to: h3)
          .get();
      expect(stats.length, 1);
      expect(stats.first.hourStart, h2);
    });

    test('cascade delete removes stats when period deleted', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: 'app1',
          nodeName: '',
          domain: '',
          rule: '',
          bytesUp: 10,
          bytesDown: 0,
          multiplier: 1.0,
          updatedAt: hour,
        ),
      ]);
      // Enable FK enforcement for cascade.
      await db.customStatement('PRAGMA foreign_keys = ON');
      await (db.delete(db.trafficBillingPeriods)
            ..where((t) => t.id.equals(p.id)))
          .go();
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats, isEmpty);
    });

    test('unattributed traffic uses special appIdentifier', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      await dao.upsertHourlyStats([
        HourlyTrafficStat(
          periodId: p.id,
          hourStart: hour,
          appIdentifier: unattributedAppIdentifier,
          nodeName: '',
          domain: '',
          rule: '',
          bytesUp: 999,
          bytesDown: 0,
          multiplier: 1.0,
          estimatedBilledBytesUp: 999,
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      final model = stats.first;
      expect(model.isUnattributed, isTrue);
      expect(model.billedBytes, 999);
    });
  });

  group('TrafficLedgerDao - node multipliers', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('upsertNodeMultiplier inserts then updates parsed', () async {
      await dao.upsertNodeMultiplier(nodeName: 'HK 2x', parsedMultiplier: 2.0);
      var rec = await dao.getNodeMultiplier('HK 2x');
      expect(rec?.parsedMultiplier, 2.0);
      expect(rec?.manualMultiplier, isNull);
      // re-upsert updates parsed.
      await dao.upsertNodeMultiplier(nodeName: 'HK 2x', parsedMultiplier: 2.5);
      rec = await dao.getNodeMultiplier('HK 2x');
      expect(rec?.parsedMultiplier, 2.5);
    });

    test('setManualMultiplier sets then clears override', () async {
      await dao.upsertNodeMultiplier(nodeName: 'HK', parsedMultiplier: 2.0);
      await dao.setManualMultiplier(nodeName: 'HK', manualMultiplier: 3.0);
      var rec = await dao.getNodeMultiplier('HK');
      expect(rec?.manualMultiplier, 3.0);
      // effective = manual ?? parsed
      expect(rec!.toModel().effectiveMultiplier, 3.0);
      // clear manual.
      await dao.setManualMultiplier(nodeName: 'HK', manualMultiplier: null);
      rec = await dao.getNodeMultiplier('HK');
      expect(rec?.manualMultiplier, isNull);
      expect(rec!.toModel().effectiveMultiplier, 2.0);
    });

    test('setManualMultiplier on non-existent node creates record', () async {
      await dao.setManualMultiplier(nodeName: 'NewNode', manualMultiplier: 1.5);
      final rec = await dao.getNodeMultiplier('NewNode');
      expect(rec, isNotNull);
      expect(rec?.manualMultiplier, 1.5);
      expect(rec?.parsedMultiplier, 1.0); // default
    });
  });

  group('TrafficLedgerDao - settings', () {
    late Database db;
    late TrafficLedgerDao dao;

    setUp(() {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
    });
    tearDown(() async => db.close());

    test('getSettings returns default when no row', () async {
      final s = await dao.getSettings();
      expect(s.autoCycleEnabled, isFalse);
      expect(s.billingCycleDay, 1);
      expect(s.billingCycleHour, 0);
    });

    test('updateSettings upserts single row', () async {
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      var s = await dao.getSettings();
      expect(s.autoCycleEnabled, isTrue);
      expect(s.billingCycleDay, 25);
      // 再次更新覆盖
      await dao.updateSettings(const LedgerSettings(
        autoCycleEnabled: false,
        billingCycleDay: 10,
      ));
      s = await dao.getSettings();
      expect(s.autoCycleEnabled, isFalse);
      expect(s.billingCycleDay, 10);
    });
  });

  group('BillingPeriodManager', () {
    late Database db;
    late BillingPeriodManager manager;

    setUp(() {
      db = _createInMemoryDb();
      manager = BillingPeriodManager(db.trafficLedgerDao);
    });
    tearDown(() async => db.close());

    test('ensureActivePeriod creates first period when none exists', () async {
      final now = DateTime(2026, 6, 25, 10);
      final p = await manager.ensureActivePeriod(now: now);
      expect(p.endAt, isNull);
      expect(p.startAt, now.millisecondsSinceEpoch);
      // second call returns same period (no new created).
      final p2 = await manager.ensureActivePeriod(now: now);
      expect(p2.id, p.id);
    });

    test('ensureActivePeriod persists across "restarts" (no clear)', () async {
      final now = DateTime(2026, 6, 25, 10);
      final p1 = await manager.ensureActivePeriod(now: now);
      // simulate app restart: new manager instance, same db.
      final manager2 = BillingPeriodManager(db.trafficLedgerDao);
      final p2 = await manager2.ensureActivePeriod(now: now);
      expect(p2.id, p1.id);
    });

    test('createNewPeriod ends old period and preserves history', () async {
      final t1 = DateTime(2026, 6, 1);
      final t2 = DateTime(2026, 6, 25, 10);
      final p1 = await manager.ensureActivePeriod(now: t1);
      final p2 = await manager.createNewPeriod(startAt: t2);
      expect(p1.id, isNot(p2.id));
      // old period still exists (history preserved).
      final all = await manager.allPeriods().get();
      expect(all.length, 2);
      // old period closed.
      final old = all.firstWhere((e) => e.id == p1.id);
      expect(old.endAt, isNotNull);
    });

    test('clearTrafficHistory wipes periods+stats; ensureActivePeriod creates fresh; multipliers preserved', () async {
      final t1 = DateTime(2026, 6, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await db.trafficLedgerDao.upsertNodeMultiplier(
        nodeName: 'n1',
        parsedMultiplier: 2.0,
      );
      await manager.clearTrafficHistory();
      expect(await manager.getActivePeriod(), isNull);
      expect(await manager.allPeriods().get(), isEmpty);
      // 节点倍率保留
      expect(await db.trafficLedgerDao.getNodeMultiplier('n1'), isNotNull);
      // ensureActivePeriod creates a brand-new period (different id).
      final p2 = await manager.ensureActivePeriod(now: t1);
      expect(p2.id, isNot(p1.id));
    });

    test('auto cycle switch via ensureActivePeriod with billingCycleDay=25', () async {
      final t1 = DateTime(2026, 6, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      // 开启自动周期，刷新日=25
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 6-26 已跨过 6-25 刷新边界，应自动切换
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 6, 26));
      expect(p2.id, isNot(p1.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      expect(start, DateTime(2026, 6, 25));
    });

    test('auto cycle no-op when within same cycle', () async {
      final t1 = DateTime(2026, 5, 26);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 6-10 还在 5-25 ~ 6-25 周期内
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 6, 10));
      expect(p2.id, p1.id);
    });

    test('auto cycle catches up across multiple missed boundaries on startup', () async {
      // 旧周期从 5-1 开始，刷新日=25
      final t1 = DateTime(2026, 5, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 应用一直未运行，7-10 才启动
      // 5-25 已过，应切换到 5-25 起的周期
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      expect(p2.id, isNot(p1.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      // nextCycleStart(5-1, 25) = 5-25
      expect(start, DateTime(2026, 5, 25));
    });
  });

  group('NodeMultiplierService', () {
    late Database db;
    late NodeMultiplierService service;

    setUp(() {
      db = _createInMemoryDb();
      service = NodeMultiplierService(db.trafficLedgerDao);
    });
    tearDown(() async => db.close());

    test('refreshParsedMultiplier stores parsed value, no manual', () async {
      final eff = await service.refreshParsedMultiplier('HK 2x');
      expect(eff, 2.0);
      final rec = await service.getRecord('HK 2x');
      expect(rec?.parsedMultiplier, 2.0);
      expect(rec?.manualMultiplier, isNull);
    });

    test('refreshParsedMultiplier preserves existing manual override', () async {
      await service.setManualMultiplier('HK 2x', 3.0);
      final eff = await service.refreshParsedMultiplier('HK 2x');
      // effective should be manual (3.0), not parsed (2.0).
      expect(eff, 3.0);
      final rec = await service.getRecord('HK 2x');
      expect(rec?.parsedMultiplier, 2.0);
      expect(rec?.manualMultiplier, 3.0);
    });

    test('getEffectiveMultiplier returns parsed when no record', () async {
      expect(await service.getEffectiveMultiplier('HK 2x'), 2.0);
      expect(await service.getEffectiveMultiplier('HK 01'), 1.0);
    });

    test('getEffectiveMultiplier returns manual when overridden', () async {
      await service.setManualMultiplier('HK 2x', 5.0);
      expect(await service.getEffectiveMultiplier('HK 2x'), 5.0);
    });

    test('clear manual override falls back to parsed', () async {
      await service.refreshParsedMultiplier('HK 2x');
      await service.setManualMultiplier('HK 2x', 5.0);
      expect(await service.getEffectiveMultiplier('HK 2x'), 5.0);
      await service.setManualMultiplier('HK 2x', null);
      expect(await service.getEffectiveMultiplier('HK 2x'), 2.0);
    });
  });

  group('HourlyTrafficStatExt', () {
    test('totalBytes and billedBytes from estimated fields', () {
      final s = HourlyTrafficStat(
        periodId: 1,
        hourStart: DateTime(2026, 6, 25, 10),
        appIdentifier: 'app1',
        nodeName: 'node1',
        domain: '',
        rule: '',
        bytesUp: 300,
        bytesDown: 700,
        multiplier: 2.0, // 展示用途
        estimatedBilledBytesUp: 600, // 300 * 2
        estimatedBilledBytesDown: 1400, // 700 * 2
        updatedAt: DateTime(2026, 6, 25, 10),
      );
      expect(s.totalBytes, 1000);
      expect(s.billedBytes, 2000); // 600 + 1400
    });

    test('billedBytes defaults to 0 when estimated fields absent', () {
      final s = HourlyTrafficStat(
        periodId: 1,
        hourStart: DateTime(2026, 6, 25, 10),
        appIdentifier: 'app1',
        nodeName: 'node1',
        domain: '',
        rule: '',
        bytesUp: 300,
        bytesDown: 700,
        updatedAt: DateTime(2026, 6, 25, 10),
      );
      expect(s.estimatedBilledBytesUp, 0);
      expect(s.estimatedBilledBytesDown, 0);
      expect(s.billedBytes, 0);
    });

    test('isUnattributed', () {
      final unattr = HourlyTrafficStat(
        periodId: 1,
        hourStart: DateTime(2026, 6, 25, 10),
        appIdentifier: unattributedAppIdentifier,
        nodeName: '',
        domain: '',
        rule: '',
        bytesUp: 100,
        bytesDown: 0,
        updatedAt: DateTime(2026, 6, 25, 10),
      );
      expect(unattr.isUnattributed, isTrue);
    });
  });

  group('BillingPeriodExt', () {
    test('isActive and status', () {
      final active = BillingPeriod(
        id: 1,
        label: null,
        startAt: DateTime(2026, 6, 1),
        endAt: null,
        createdAt: DateTime(2026, 6, 1),
      );
      expect(active.isActive, isTrue);
      expect(active.status, BillingPeriodStatus.active);
      final closed = active.copyWith(endAt: DateTime(2026, 6, 25));
      expect(closed.isActive, isFalse);
      expect(closed.status, BillingPeriodStatus.closed);
    });

    test('covers', () {
      final p = BillingPeriod(
        id: 1,
        label: null,
        startAt: DateTime(2026, 6, 1),
        endAt: DateTime(2026, 6, 25),
        createdAt: DateTime(2026, 6, 1),
      );
      expect(p.covers(DateTime(2026, 6, 10)), isTrue);
      expect(p.covers(DateTime(2026, 5, 30)), isFalse);
      expect(p.covers(DateTime(2026, 6, 25)), isFalse); // exclusive end
      expect(p.covers(DateTime(2026, 6, 1)), isTrue); // inclusive start
    });
  });

  group('NodeMultiplierExt', () {
    test('effectiveMultiplier and isManualOverridden', () {
      final auto = NodeMultiplier(
        nodeName: 'n',
        parsedMultiplier: 2.0,
        manualMultiplier: null,
        updatedAt: DateTime(2026, 6, 1),
      );
      expect(auto.effectiveMultiplier, 2.0);
      expect(auto.isManualOverridden, isFalse);
      final manual = auto.copyWith(manualMultiplier: 3.0);
      expect(manual.effectiveMultiplier, 3.0);
      expect(manual.isManualOverridden, isTrue);
    });
  });

  group('LedgerSettings', () {
    test('default values', () {
      const s = defaultLedgerSettings;
      expect(s.autoCycleEnabled, isFalse);
      expect(s.billingCycleDay, 1);
      expect(s.billingCycleHour, 0);
      expect(s.updatedAt, isNull);
    });

    test('isValidCycleDay', () {
      expect(const LedgerSettings(billingCycleDay: 1).isValidCycleDay, isTrue);
      expect(const LedgerSettings(billingCycleDay: 28).isValidCycleDay, isTrue);
      expect(const LedgerSettings(billingCycleDay: 0).isValidCycleDay, isFalse);
      expect(const LedgerSettings(billingCycleDay: 29).isValidCycleDay, isFalse);
      expect(const LedgerSettings(billingCycleDay: 31).isValidCycleDay, isFalse);
    });
  });

  group('BillingCycleCalculator', () {
    test('cycleStartFor: moment before refresh day belongs to previous month', () {
      // 6-10, day=25 → 5-25
      expect(
        BillingCycleCalculator.cycleStartFor(DateTime(2026, 6, 10), 25),
        DateTime(2026, 5, 25),
      );
    });

    test('cycleStartFor: moment on/after refresh day belongs to current month', () {
      // 6-25, day=25 → 6-25
      expect(
        BillingCycleCalculator.cycleStartFor(DateTime(2026, 6, 25), 25),
        DateTime(2026, 6, 25),
      );
      // 6-30, day=25 → 6-25
      expect(
        BillingCycleCalculator.cycleStartFor(DateTime(2026, 6, 30), 25),
        DateTime(2026, 6, 25),
      );
    });

    test('cycleStartFor: January rolls back to December of previous year', () {
      // 1-10, day=25 → 12-25 of previous year
      expect(
        BillingCycleCalculator.cycleStartFor(DateTime(2026, 1, 10), 25),
        DateTime(2025, 12, 25),
      );
    });

    test('cycleStartFor: day=1 equals natural month start', () {
      expect(
        BillingCycleCalculator.cycleStartFor(DateTime(2026, 6, 15), 1),
        DateTime(2026, 6, 1),
      );
    });

    test('nextCycleStart: currentStart on refresh day returns next month', () {
      // 6-25, day=25 → 7-25
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 6, 25), 25),
        DateTime(2026, 7, 25),
      );
    });

    test('nextCycleStart: currentStart before refresh day returns current month', () {
      // 6-1, day=25 → 6-25
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 6, 1), 25),
        DateTime(2026, 6, 25),
      );
    });

    test('nextCycleStart: currentStart after refresh day returns next month', () {
      // 6-26, day=25 → 7-25
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 6, 26), 25),
        DateTime(2026, 7, 25),
      );
    });

    test('nextCycleStart: December rolls over to January next year', () {
      // 12-26, day=25 → 1-25 next year
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 12, 26), 25),
        DateTime(2027, 1, 25),
      );
    });

    test('nextCycleStart: day=1 equals natural month boundary', () {
      // 6-1, day=1 → 7-1
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 6, 1), 1),
        DateTime(2026, 7, 1),
      );
    });

    test('nextCycleStart: respects billingCycleHour', () {
      // 6-25 12:00, day=25, hour=0 → 7-25 00:00
      expect(
        BillingCycleCalculator.nextCycleStart(
          DateTime(2026, 6, 25, 12),
          25,
          0,
        ),
        DateTime(2026, 7, 25, 0),
      );
    });

    test('nextCycleStart: clamps invalid day to 28', () {
      // day=31 被钳制为 28
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 6, 1), 31),
        DateTime(2026, 6, 28),
      );
    });
  });
}
