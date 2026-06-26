import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_cycle_calculator.dart';

part 'converter.dart';
part 'generated/database.g.dart';
part 'groups.dart';
part 'icons.dart';
part 'links.dart';
part 'profiles.dart';
part 'rules.dart';
part 'scripts.dart';
part 'traffic_ledger.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Scripts,
    Rules,
    ProfileRuleLinks,
    ProxyGroups,
    IconRecords,
    TrafficBillingPeriods,
    TrafficHourlyStats,
    TrafficNodeMultipliers,
    TrafficLedgerSettings,
  ],
  daos: [
    ProfilesDao,
    ScriptsDao,
    RulesDao,
    ProxyGroupsDao,
    IconRecordsDao,
    TrafficLedgerDao,
  ],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(proxyGroups);
          await m.createTable(iconRecords);
          await _resetOrders();
          await _migrateRules(m);
        }
        if (from < 3) {
          // Traffic Ledger: 计费周期、小时聚合流量、节点倍率。
          await m.createTable(trafficBillingPeriods);
          await m.createTable(trafficHourlyStats);
          await m.createTable(trafficNodeMultipliers);
          await m.createIndex(idxTrafficPeriodHour);
          await m.createIndex(idxTrafficApp);
          await m.createIndex(idxTrafficNode);
        }
        if (from < 4) {
          // Stage 2.1 修正：
          // 1. 小时聚合表新增预计扣量累计列（默认 0）。
          await m.addColumn(
            trafficHourlyStats,
            trafficHourlyStats.estimatedBilledBytesUp,
          );
          await m.addColumn(
            trafficHourlyStats,
            trafficHourlyStats.estimatedBilledBytesDown,
          );
          // 2. 回填旧记录的预计扣量：旧 multiplier 视为入账时快照，
          //    按 bytes * multiplier 计算 estimated 值。开发版尚未真实
          //    采集用户流量，旧记录通常为空或测试数据，回填安全。
          await customStatement(
            'UPDATE traffic_hourly_stats SET '
            'estimated_billed_bytes_up = CAST(bytes_up * multiplier AS INTEGER), '
            'estimated_billed_bytes_down = CAST(bytes_down * multiplier AS INTEGER)',
          );
          // 3. 计费周期表移除 autoMonthSwitch 列（重建表）。
          //    自动周期配置迁移到独立的 traffic_ledger_settings 表。
          await m.alterTable(
            TableMigration(trafficBillingPeriods),
          );
          // 4. 新增流量账本设置表（单行表）。
          await m.createTable(trafficLedgerSettings);
        }
      },
      beforeOpen: (details) async {
        // final m = Migrator(this);
        // await m.createTable(iconRecords);
        // await _migrateRules(m);
        // await m.deleteTable('proxy_groups');
        // await m.createTable(proxyGroups);
      },
    );
  }

  Future<void> _migrateRules(Migrator m) async {
    final tableInfo = await customSelect('PRAGMA table_info(rules)').get();
    final columnNames = tableInfo
        .map((row) => row.read<String>('name'))
        .toList();
    if (columnNames.isEmpty) {
      await m.createTable(rules);
      return;
    } else if (columnNames.contains('rule_action')) {
      return;
    }
    await customStatement(
      'ALTER TABLE rules ADD COLUMN rule_action TEXT NOT NULL DEFAULT ""',
    );
    await customStatement('ALTER TABLE rules ADD COLUMN content TEXT');
    await customStatement('ALTER TABLE rules ADD COLUMN rule_target TEXT');
    await customStatement('ALTER TABLE rules ADD COLUMN rule_provider TEXT');
    await customStatement('ALTER TABLE rules ADD COLUMN sub_rule TEXT');
    await customStatement(
      'ALTER TABLE rules ADD COLUMN no_resolve INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement(
      'ALTER TABLE rules ADD COLUMN src INTEGER NOT NULL DEFAULT 0',
    );
    final oldRows = await customSelect('SELECT id, value FROM rules').get();
    for (final row in oldRows) {
      final id = row.read<int>('id');
      final value = row.read<String>('value');
      final parsed = Rule.parse(value, id: id);
      await customStatement(
        'UPDATE rules SET rule_action = ?, content = ?, rule_target = ?, rule_provider = ?, sub_rule = ?, no_resolve = ?, src = ? WHERE id = ?',
        [
          parsed.ruleAction.name,
          parsed.content,
          parsed.ruleTarget,
          parsed.ruleProvider,
          parsed.subRule,
          parsed.noResolve ? 1 : 0,
          parsed.src ? 1 : 0,
          id,
        ],
      );
    }
    await customStatement('ALTER TABLE rules DROP COLUMN value');
    await m.createIndex(idxRuleTarget);
  }

  Future<void> _resetOrders() async {
    await rulesDao.resetOrders();
  }

  Future<void> restore(
    List<Profile> profiles,
    List<Script> scripts,
    List<Rule> rules,
    List<ProfileRuleLink> links,
    List<ProxyGroup> proxyGroups, {
    bool isOverride = false,
  }) async {
    if (profiles.isNotEmpty ||
        scripts.isNotEmpty ||
        rules.isNotEmpty ||
        links.isNotEmpty) {
      await batch((b) {
        isOverride
            ? profilesDao.setAllWithBatch(b, profiles)
            : profilesDao.putAllWithBatch(
                b,
                profiles.map((item) => item.toCompanion()),
              );
        scriptsDao.setAllWithBatch(b, scripts);
        rulesDao.restoreWithBatch(b, rules, links);
        proxyGroupsDao.setAllWithBatch(null, b, proxyGroups);
      });
    }
  }

  Future<void> setProfileCustomData(
    int profileId,
    List<ProxyGroup> groups,
    List<Rule> rules,
  ) async {
    await batch((b) {
      proxyGroupsDao.setAllWithBatch(profileId, b, groups);
      rulesDao.setCustomRulesWithBatch(profileId, b, rules);
    });
  }
}

extension TableInfoExt<Tbl extends Table, Row> on TableInfo<Tbl, Row> {
  void setAll(
    Batch batch,
    Iterable<Insertable<Row>> items, {
    required Expression<bool> Function(Tbl tbl) deleteFilter,
    bool preDelete = false,
  }) async {
    if (preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
    batch.insertAllOnConflictUpdate(this, items);
    if (!preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
  }

  Selectable<int?> get count {
    final countExp = countAll();
    final query = select().addColumns([countExp]);
    return query.map((row) => row.read(countExp));
  }

  Future<int> remove(Expression<bool> Function(Tbl tbl) filter) async {
    return (delete()..where(filter)).go();
  }

  Future<int> put(Insertable<Row> item) async {
    return insertOnConflictUpdate(item);
  }
}

extension SimpleSelectStatementExt<T extends HasResultSet, D>
    on SimpleSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    final query = addColumns([countExp]);
    return query.map((row) => row.read(countExp)!);
  }
}

extension JoinedSelectStatementExt<T extends HasResultSet, D>
    on JoinedSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    addColumns([countExp]);
    return map((row) => row.read(countExp)!);
  }
}

final database = Database();
