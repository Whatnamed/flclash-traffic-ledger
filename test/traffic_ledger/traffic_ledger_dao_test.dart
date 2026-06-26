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
      // 5-25、6-25 都已过，当前所属周期为 6-25 ~ 7-25
      // 多边界追赶（Stage 2.3 修正）：
      //   - 旧周期 endAt = 5-25（第一个真实刷新边界，不延长到 6-25）
      //   - 新活动周期 startAt = 6-25（当前所属周期）
      //   - 中间空周期不创建
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      expect(p2.id, isNot(p1.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      expect(start, DateTime(2026, 6, 25));
      final all = await manager.allPeriods().get();
      // 旧周期 endAt = 5-25
      final old = all.firstWhere((e) => e.id == p1.id);
      expect(
        DateTime.fromMillisecondsSinceEpoch(old.endAt!),
        DateTime(2026, 5, 25),
      );
      // 新活动周期 endAt = null
      final activePeriods = all.where((e) => e.endAt == null).toList();
      expect(activePeriods.length, 1);
      expect(activePeriods.first.id, p2.id);
      // 不存在 startAt = 5-25 的周期（中间空周期不创建）
      final may25 = all.where((e) =>
          DateTime.fromMillisecondsSinceEpoch(e.startAt) ==
          DateTime(2026, 5, 25)).toList();
      expect(may25, isEmpty);
    });

    test('auto cycle catch up: old 5-1, day=25, now 8-26 -> active startAt 8-25, old endAt 5-25', () async {
      final t1 = DateTime(2026, 5, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 8-26 当前所属周期为 8-25 ~ 9-25
      // 旧周期遇到第一个真实刷新边界为 5-25
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 8, 26));
      expect(p2.id, isNot(p1.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      expect(start, DateTime(2026, 8, 25));
      final all = await manager.allPeriods().get();
      final old = all.firstWhere((e) => e.id == p1.id);
      expect(
        DateTime.fromMillisecondsSinceEpoch(old.endAt!),
        DateTime(2026, 5, 25),
      );
      // 中间空周期不创建
      expect(all.length, 2); // 仅旧周期 + 当前周期
    });

    test('single boundary switch: old 6-1, day=25, now 6-26 -> old endAt = new startAt = 6-25', () async {
      // 单边界场景：firstMissedBoundary == currentCycleStart
      final t1 = DateTime(2026, 6, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 6, 26));
      expect(p2.id, isNot(p1.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      expect(start, DateTime(2026, 6, 25));
      final all = await manager.allPeriods().get();
      final old = all.firstWhere((e) => e.id == p1.id);
      expect(
        DateTime.fromMillisecondsSinceEpoch(old.endAt!),
        DateTime(2026, 6, 25),
      );
      // 单边界场景无空档
      expect(all.length, 2);
    });

    test('manual period followed by auto boundary switch', () async {
      // 自动周期启用，billingCycleDay=25
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 用户手动在 6-15 10:30 创建新周期
      final manualNow = DateTime(2026, 6, 15, 10, 30);
      final pManual = await manager.createNewPeriod(startAt: manualNow);
      // 当前时间到 7-10，应自动切换
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      expect(p2.id, isNot(pManual.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      expect(start, DateTime(2026, 6, 25));
      final all = await manager.allPeriods().get();
      // 手动周期在 6-25 结束（第一个真实刷新边界）
      final old = all.firstWhere((e) => e.id == pManual.id);
      expect(
        DateTime.fromMillisecondsSinceEpoch(old.endAt!),
        DateTime(2026, 6, 25),
      );
    });

    test('maybeAutoCycleSwitch idempotent: second call no-op after catch-up', () async {
      final t1 = DateTime(2026, 5, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 第一次追赶
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      expect(p2.id, isNot(p1.id));
      // 第二次调用：活动周期已对齐当前所属周期，不应再创建
      final p3 = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      expect(p3.id, p2.id);
      final all = await manager.allPeriods().get();
      expect(all.length, 2); // 旧 + 当前，无重复
      final activePeriods = all.where((e) => e.endAt == null).toList();
      expect(activePeriods.length, 1);
    });

    test('auto cycle on, no active period, now 7-10, day=25 -> new period startAt 6-25', () async {
      // 先开启自动周期（此时无活动周期）
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 7-10 当前所属周期为 6-25 ~ 7-25
      final p = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      final start = DateTime.fromMillisecondsSinceEpoch(p.startAt);
      expect(start, DateTime(2026, 6, 25));
    });

    test('auto cycle off, no active period, now 7-10 -> new period startAt = now', () async {
      // 自动周期关闭（默认），无活动周期
      final now = DateTime(2026, 7, 10, 14, 30);
      final p = await manager.ensureActivePeriod(now: now);
      final start = DateTime.fromMillisecondsSinceEpoch(p.startAt);
      expect(start, now);
    });

    test('manual createNewPeriod always starts from now regardless of auto cycle', () async {
      // 开启自动周期
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 先建一个活动周期
      await manager.ensureActivePeriod(now: DateTime(2026, 6, 1));
      // 手动新建周期，应从用户点击时刻开始，不被自动周期逻辑覆盖
      final manualNow = DateTime(2026, 6, 15, 10, 30);
      final p = await manager.createNewPeriod(startAt: manualNow);
      final start = DateTime.fromMillisecondsSinceEpoch(p.startAt);
      expect(start, manualNow);
    });

    test('manual createNewPeriod with default startAt uses current moment', () async {
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      await manager.ensureActivePeriod(now: DateTime(2026, 6, 1));
      // 不传 startAt，应使用 DateTime.now()（当前时刻，非 cycleStartFor）
      final p = await manager.createNewPeriod();
      // 只验证 endAt 为 null（活动周期），startAt 不做精确比较（依赖系统时间）
      expect(p.endAt, isNull);
      final start = DateTime.fromMillisecondsSinceEpoch(p.startAt);
      // startAt 应在"现在"附近（1 分钟内），而不是对齐到某个刷新边界
      final systemNow = DateTime.now();
      expect(start.isAfter(systemNow.subtract(const Duration(minutes: 1))), isTrue);
      expect(start.isBefore(systemNow.add(const Duration(minutes: 1))), isTrue);
    });

    test('within current cycle: no duplicate period, no startAt change', () async {
      final t1 = DateTime(2026, 5, 26);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updateSettings(const LedgerSettings(
        autoCycleEnabled: true,
        billingCycleDay: 25,
      ));
      // 6-10 还在 5-25 ~ 6-25 周期内，不应切换
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 6, 10));
      expect(p2.id, p1.id);
      expect(p2.startAt, p1.startAt);
      // 只有一个周期
      final all = await manager.allPeriods().get();
      expect(all.length, 1);
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

    test('nextCycleStart: clamps invalid day to 28', () async {
      // day=31 被钳制为 28
      expect(
        BillingCycleCalculator.nextCycleStart(DateTime(2026, 6, 1), 31),
        DateTime(2026, 6, 28),
      );
    });
  });

  // ===== Stage 4A: 聚合查询测试 =====

  group('TrafficLedgerDao - Stage 4A aggregations', () {
    late Database db;
    late TrafficLedgerDao dao;
    late int periodId;

    setUp(() async {
      db = _createInMemoryDb();
      dao = db.trafficLedgerDao;
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      periodId = p.id;
    });
    tearDown(() async => db.close());

    HourlyTrafficStat makeStat({
      required String appIdentifier,
      required String nodeName,
      required int bytesUp,
      required int bytesDown,
      int estimatedBilledBytesUp = 0,
      int estimatedBilledBytesDown = 0,
      int billedRemainderUp = 0,
      int billedRemainderDown = 0,
      DateTime? hourStart,
    }) {
      final h = hourStart ?? _hourStart(DateTime(2026, 6, 25, 10));
      return HourlyTrafficStat(
        periodId: periodId,
        hourStart: h,
        appIdentifier: appIdentifier,
        nodeName: nodeName,
        domain: '',
        rule: '',
        bytesUp: bytesUp,
        bytesDown: bytesDown,
        estimatedBilledBytesUp: estimatedBilledBytesUp,
        estimatedBilledBytesDown: estimatedBilledBytesDown,
        billedRemainderUp: billedRemainderUp,
        billedRemainderDown: billedRemainderDown,
        updatedAt: h,
      );
    }

    test('queryPeriodOverview: empty period returns all zeros, no exception', () async {
      final ov = await dao.queryPeriodOverview(periodId: periodId);
      expect(ov.bytesUp, 0);
      expect(ov.bytesDown, 0);
      expect(ov.totalBytes, 0);
      expect(ov.totalEstimatedBilled, 0);
      expect(ov.totalUnbilled, 0);
      expect(ov.isEmpty, isTrue);
      expect(ov.billingCoverage, 1.0);
    });

    test('queryPeriodOverview: aggregates actual + estimated + upload/download', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 2000,
          estimatedBilledBytesUp: 2000,
          estimatedBilledBytesDown: 4000,
        ),
        makeStat(
          appIdentifier: 'c:/app/firefox.exe',
          nodeName: 'JP-1x',
          bytesUp: 500,
          bytesDown: 300,
          estimatedBilledBytesUp: 500,
          estimatedBilledBytesDown: 300,
        ),
      ]);
      final ov = await dao.queryPeriodOverview(periodId: periodId);
      expect(ov.bytesUp, 1500);
      expect(ov.bytesDown, 2300);
      expect(ov.totalBytes, 3800);
      expect(ov.estimatedBilledBytesUp, 2500);
      expect(ov.estimatedBilledBytesDown, 4300);
      expect(ov.totalEstimatedBilled, 6800);
      expect(ov.totalUnbilled, 0);
      expect(ov.isEmpty, isFalse);
    });

    test('queryPeriodOverview: unbilled (sentinel -1) excluded from estimated', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 2000,
          estimatedBilledBytesUp: 2000,
          estimatedBilledBytesDown: 4000,
          billedRemainderUp: 0,
          billedRemainderDown: 0,
        ),
        // 不可估算行：billedRemainder = -1
        makeStat(
          appIdentifier: unattributedAppIdentifier,
          nodeName: '',
          bytesUp: 500,
          bytesDown: 0,
          estimatedBilledBytesUp: 0,
          estimatedBilledBytesDown: 0,
          billedRemainderUp: -1,
          billedRemainderDown: -1,
        ),
      ]);
      final ov = await dao.queryPeriodOverview(periodId: periodId);
      // 实际流量含未归因
      expect(ov.bytesUp, 1500);
      expect(ov.bytesDown, 2000);
      expect(ov.totalBytes, 3500);
      // 预计扣量不含 sentinel 行
      expect(ov.estimatedBilledBytesUp, 2000);
      expect(ov.estimatedBilledBytesDown, 4000);
      expect(ov.totalEstimatedBilled, 6000);
      // unbilled = sentinel 行的实际流量
      expect(ov.unbilledBytesUp, 500);
      expect(ov.unbilledBytesDown, 0);
      expect(ov.totalUnbilled, 500);
      // 覆盖率 = 1 - 500/3500
      expect(ov.billingCoverage, closeTo(1 - 500 / 3500, 0.001));
    });

    test('queryPeriodOverview: estimated uses persisted fields, not current multiplier', () async {
      // 入账时倍率 2x, estimated = 2000
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 0,
          estimatedBilledBytesUp: 2000,
        ),
      ]);
      // 之后修改节点倍率
      await dao.setManualMultiplier(nodeName: 'HK-2x', manualMultiplier: 10.0);
      // 查询应仍返回 persisted estimated = 2000，不是 1000*10
      final ov = await dao.queryPeriodOverview(periodId: periodId);
      expect(ov.estimatedBilledBytesUp, 2000);
      expect(ov.totalEstimatedBilled, 2000);
    });

    test('queryUnattributedOverview: isolates unattributed traffic', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 2000,
          estimatedBilledBytesUp: 2000,
          estimatedBilledBytesDown: 4000,
        ),
        makeStat(
          appIdentifier: unattributedAppIdentifier,
          nodeName: '',
          bytesUp: 999,
          bytesDown: 1,
          estimatedBilledBytesUp: 999,
          estimatedBilledBytesDown: 1,
          billedRemainderUp: 0,
          billedRemainderDown: 0,
        ),
      ]);
      final ov = await dao.queryUnattributedOverview(periodId: periodId);
      expect(ov.bytesUp, 999);
      expect(ov.bytesDown, 1);
      expect(ov.totalBytes, 1000);
      expect(ov.estimatedBilledBytesUp, 999);
      expect(ov.estimatedBilledBytesDown, 1);
    });

    test('queryUnattributedOverview: zero when no unattributed rows', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 2000,
          estimatedBilledBytesUp: 2000,
        ),
      ]);
      final ov = await dao.queryUnattributedOverview(periodId: periodId);
      expect(ov.totalBytes, 0);
      expect(ov.isEmpty, isTrue);
    });

    test('queryAppAggregations: orders by total actual bytes desc', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/small.exe',
          nodeName: 'HK-2x',
          bytesUp: 100,
          bytesDown: 100,
          estimatedBilledBytesUp: 200,
          estimatedBilledBytesDown: 200,
        ),
        makeStat(
          appIdentifier: 'c:/app/big.exe',
          nodeName: 'HK-2x',
          bytesUp: 5000,
          bytesDown: 5000,
          estimatedBilledBytesUp: 10000,
          estimatedBilledBytesDown: 10000,
        ),
        makeStat(
          appIdentifier: 'c:/app/medium.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 1000,
          estimatedBilledBytesUp: 2000,
          estimatedBilledBytesDown: 2000,
        ),
      ]);
      final apps = await dao.queryAppAggregations(periodId: periodId);
      expect(apps.length, 3);
      expect(apps[0].appIdentifier, 'c:/app/big.exe');
      expect(apps[0].totalBytes, 10000);
      expect(apps[1].appIdentifier, 'c:/app/medium.exe');
      expect(apps[1].totalBytes, 2000);
      expect(apps[2].appIdentifier, 'c:/app/small.exe');
      expect(apps[2].totalBytes, 200);
    });

    test('queryAppAggregations: same basename different path = separate items', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app1/node.exe',
          nodeName: 'HK-2x',
          bytesUp: 100,
          bytesDown: 0,
          estimatedBilledBytesUp: 200,
        ),
        makeStat(
          appIdentifier: 'c:/app2/node.exe',
          nodeName: 'HK-2x',
          bytesUp: 200,
          bytesDown: 0,
          estimatedBilledBytesUp: 400,
        ),
      ]);
      final apps = await dao.queryAppAggregations(periodId: periodId);
      expect(apps.length, 2);
      // 两个 node.exe 是不同聚合项
      final ids = apps.map((a) => a.appIdentifier).toSet();
      expect(ids.contains('c:/app1/node.exe'), isTrue);
      expect(ids.contains('c:/app2/node.exe'), isTrue);
    });

    test('queryAppAggregations: unattributed excluded from app list', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 0,
          estimatedBilledBytesUp: 2000,
        ),
        makeStat(
          appIdentifier: unattributedAppIdentifier,
          nodeName: '',
          bytesUp: 999,
          bytesDown: 0,
        ),
      ]);
      final apps = await dao.queryAppAggregations(periodId: periodId);
      expect(apps.length, 1);
      expect(apps[0].appIdentifier, 'c:/app/chrome.exe');
      // 未归因项不出现在应用列表
      expect(
        apps.any((a) => a.appIdentifier == unattributedAppIdentifier),
        isFalse,
      );
    });

    test('queryAppAggregations: empty period returns empty list', () async {
      final apps = await dao.queryAppAggregations(periodId: periodId);
      expect(apps, isEmpty);
    });

    test('queryAppAggregations: aggregates across hours + nodes for same app', () async {
      final h1 = _hourStart(DateTime(2026, 6, 25, 10));
      final h2 = _hourStart(DateTime(2026, 6, 25, 11));
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 0,
          estimatedBilledBytesUp: 2000,
          hourStart: h1,
        ),
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'JP-1x',
          bytesUp: 500,
          bytesDown: 200,
          estimatedBilledBytesUp: 500,
          estimatedBilledBytesDown: 200,
          hourStart: h2,
        ),
      ]);
      final apps = await dao.queryAppAggregations(periodId: periodId);
      expect(apps.length, 1);
      expect(apps[0].appIdentifier, 'c:/app/chrome.exe');
      expect(apps[0].bytesUp, 1500);
      expect(apps[0].bytesDown, 200);
      expect(apps[0].totalBytes, 1700);
      expect(apps[0].estimatedBilledBytesUp, 2500);
      expect(apps[0].estimatedBilledBytesDown, 200);
    });

    test('queryAppAggregations: hasUnbilled flag set when any row has sentinel', () async {
      await dao.upsertHourlyStats([
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'HK-2x',
          bytesUp: 1000,
          bytesDown: 0,
          estimatedBilledBytesUp: 2000,
          billedRemainderUp: 0,
        ),
        // 同一应用的另一行不可估算
        makeStat(
          appIdentifier: 'c:/app/chrome.exe',
          nodeName: 'unknown-node',
          bytesUp: 500,
          bytesDown: 0,
          estimatedBilledBytesUp: 0,
          billedRemainderUp: -1,
          hourStart: _hourStart(DateTime(2026, 6, 25, 11)),
        ),
      ]);
      final apps = await dao.queryAppAggregations(periodId: periodId);
      expect(apps.length, 1);
      expect(apps[0].hasUnbilled, isTrue);
    });
  });
}
