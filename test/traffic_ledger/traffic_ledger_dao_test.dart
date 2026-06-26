import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/node_multiplier_service.dart';
import 'package:test/test.dart';

/// 创建内存数据库用于测试。每个测试独立实例，避免相互干扰。
Database _createInMemoryDb() {
  return Database(NativeDatabase.memory());
}

DateTime _hourStart(DateTime t) =>
    DateTime(t.year, t.month, t.day, t.hour);

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

    test('maybeAutoMonthSwitch does nothing when autoMonthSwitch off', () async {
      final t1 = DateTime(2026, 6, 1);
      await dao.startNewPeriod(startAt: t1, autoMonthSwitch: false);
      final result = await dao.maybeAutoMonthSwitch(now: DateTime(2026, 7, 15));
      expect(result, isNull);
      final all = await dao.allPeriods().get();
      expect(all.length, 1);
    });

    test('maybeAutoMonthSwitch creates new period when crossed month', () async {
      final t1 = DateTime(2026, 6, 1);
      final p = await dao.startNewPeriod(startAt: t1, autoMonthSwitch: true);
      final newPeriod = await dao.maybeAutoMonthSwitch(now: DateTime(2026, 7, 15));
      expect(newPeriod, isNotNull);
      expect(newPeriod!.id, isNot(p.id));
      expect(newPeriod.autoMonthSwitch, isTrue);
      // new period starts at month beginning.
      final start = DateTime.fromMillisecondsSinceEpoch(newPeriod.startAt);
      expect(start, DateTime(2026, 7, 1));
      // old period closed.
      final old = await (db.select(db.trafficBillingPeriods)
            ..where((t) => t.id.equals(p.id)))
          .getSingle();
      expect(old.endAt, isNotNull);
    });

    test('maybeAutoMonthSwitch no-op when same month', () async {
      await dao.startNewPeriod(
        startAt: DateTime(2026, 6, 1),
        autoMonthSwitch: true,
      );
      final result = await dao.maybeAutoMonthSwitch(now: DateTime(2026, 6, 25));
      expect(result, isNull);
    });

    test('updatePeriod updates label and autoMonthSwitch', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      await dao.updatePeriod(p.id, label: 'June', autoMonthSwitch: true);
      final updated = await (db.select(db.trafficBillingPeriods)
            ..where((t) => t.id.equals(p.id)))
          .getSingle();
      expect(updated.label, 'June');
      expect(updated.autoMonthSwitch, isTrue);
    });

    test('clearAllHistory deletes everything but is distinct from new period', () async {
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
      await dao.clearAllHistory();
      expect(await dao.getActivePeriod(), isNull);
      expect(await dao.allPeriods().get(), isEmpty);
      expect(await dao.getNodeMultiplier('node1'), isNull);
      final stats = await dao
          .queryHourlyStats(periodId: p.id)
          .get();
      expect(stats, isEmpty);
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
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 100);
      expect(stats.first.bytesDown, 200);
      expect(stats.first.multiplier, 2.0);
    });

    test('upsertHourlyStats accumulates bytes on same key', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      final base = HourlyTrafficStat(
        periodId: p.id,
        hourStart: hour,
        appIdentifier: 'app1',
        nodeName: 'node1',
        domain: '',
        rule: '',
        bytesUp: 100,
        bytesDown: 200,
        multiplier: 2.0,
        updatedAt: hour,
      );
      await dao.upsertHourlyStats([base]);
      // second flush, same key, different bytes.
      await dao.upsertHourlyStats([
        base.copyWith(bytesUp: 50, bytesDown: 70, updatedAt: hour),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 150);
      expect(stats.first.bytesDown, 270);
    });

    test('multiplier preserved on accumulation (history immutability)', () async {
      final p = await dao.startNewPeriod(startAt: DateTime(2026, 6, 1));
      final hour = _hourStart(DateTime(2026, 6, 25, 10));
      // First write with multiplier 2.0.
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
          updatedAt: hour,
        ),
      ]);
      // Second write with multiplier 3.0 (simulating user changed multiplier).
      // Existing record keeps original multiplier 2.0.
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
          updatedAt: hour,
        ),
      ]);
      final stats = await dao.queryHourlyStats(periodId: p.id).get();
      expect(stats.length, 1);
      expect(stats.first.multiplier, 2.0); // preserved, not 3.0
      expect(stats.first.bytesUp, 150);
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

    test('clearAllHistory wipes everything; ensureActivePeriod creates fresh',
        () async {
      final t1 = DateTime(2026, 6, 1);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await db.trafficLedgerDao.upsertNodeMultiplier(
        nodeName: 'n1',
        parsedMultiplier: 2.0,
      );
      await manager.clearAllHistory();
      expect(await manager.getActivePeriod(), isNull);
      expect(await manager.allPeriods().get(), isEmpty);
      expect(await db.trafficLedgerDao.getNodeMultiplier('n1'), isNull);
      // ensureActivePeriod creates a brand-new period (different id).
      final p2 = await manager.ensureActivePeriod(now: t1);
      expect(p2.id, isNot(p1.id));
    });

    test('auto month switch via ensureActivePeriod', () async {
      final t1 = DateTime(2026, 6, 15);
      final p1 = await manager.ensureActivePeriod(now: t1);
      await manager.updatePeriod(p1.id, autoMonthSwitch: true);
      // July: should auto-switch.
      final p2 = await manager.ensureActivePeriod(now: DateTime(2026, 7, 10));
      expect(p2.id, isNot(p1.id));
      final start = DateTime.fromMillisecondsSinceEpoch(p2.startAt);
      expect(start, DateTime(2026, 7, 1));
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
    test('totalBytes and billedBytes', () {
      final s = HourlyTrafficStat(
        periodId: 1,
        hourStart: DateTime(2026, 6, 25, 10),
        appIdentifier: 'app1',
        nodeName: 'node1',
        domain: '',
        rule: '',
        bytesUp: 300,
        bytesDown: 700,
        multiplier: 2.0,
        updatedAt: DateTime(2026, 6, 25, 10),
      );
      expect(s.totalBytes, 1000);
      expect(s.billedBytes, 2000);
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
        multiplier: 1.0,
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
}
