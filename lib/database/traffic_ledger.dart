part of 'database.dart';

/// 计费周期表。当前活动周期 endAt 为 null；用户手动"新建计费周期"或
/// 开启自动月度切换时结束旧周期（设置 endAt）并创建新周期。
@DataClassName('TrafficBillingPeriod')
class TrafficBillingPeriods extends Table {
  @override
  String get tableName => 'traffic_billing_periods';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get label => text().nullable()();

  /// 周期开始时间（epoch millis）。
  IntColumn get startAt => integer()();

  /// 周期结束时间（epoch millis）。null 表示当前活动周期。
  IntColumn get endAt => integer().nullable()();

  /// 是否按月自动切换周期。
  BoolColumn get autoMonthSwitch => boolean().withDefault(const Constant(false))();

  IntColumn get createdAt => integer()();
}

/// 按小时聚合的流量统计表。长期只保存小时级聚合，不保存连接明细。
/// 组合主键：(periodId, hourStart, appIdentifier, nodeName, domain, rule)。
/// [multiplier] 为入账时倍率快照，修改节点倍率不回写历史。
@DataClassName('TrafficHourlyStat')
@TableIndex(
  name: 'idx_traffic_period_hour',
  columns: {#periodId, #hourStart},
)
@TableIndex(
  name: 'idx_traffic_app',
  columns: {#periodId, #appIdentifier},
)
@TableIndex(
  name: 'idx_traffic_node',
  columns: {#periodId, #nodeName},
)
class TrafficHourlyStats extends Table {
  @override
  String get tableName => 'traffic_hourly_stats';

  IntColumn get periodId => integer().references(
    TrafficBillingPeriods,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 小时起始时间（epoch millis，对齐到整点）。
  IntColumn get hourStart => integer()();

  /// 应用标识。'' = 未知，'__unattributed__' = 未归因代理流量。
  TextColumn get appIdentifier => text().withDefault(const Constant(''))();

  /// 节点名。'' = 未知。
  TextColumn get nodeName => text().withDefault(const Constant(''))();

  /// 域名。'' = 未知。
  TextColumn get domain => text().withDefault(const Constant(''))();

  /// 规则。'' = 未知。
  TextColumn get rule => text().withDefault(const Constant(''))();

  IntColumn get bytesUp => integer().withDefault(const Constant(0))();

  IntColumn get bytesDown => integer().withDefault(const Constant(0))();

  /// 入账时倍率快照。
  RealColumn get multiplier => real().withDefault(const Constant(1.0))();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey =>
      {periodId, hourStart, appIdentifier, nodeName, domain, rule};
}

/// 节点倍率表。[parsedMultiplier] 自动解析，[manualMultiplier] 用户手动覆盖。
@DataClassName('TrafficNodeMultiplier')
class TrafficNodeMultipliers extends Table {
  @override
  String get tableName => 'traffic_node_multipliers';

  TextColumn get nodeName => text()();

  RealColumn get parsedMultiplier => real().withDefault(const Constant(1.0))();

  RealColumn get manualMultiplier => real().nullable()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {nodeName};
}

@DriftAccessor(tables: [TrafficBillingPeriods, TrafficHourlyStats, TrafficNodeMultipliers])
class TrafficLedgerDao extends DatabaseAccessor<Database>
    with _$TrafficLedgerDaoMixin {
  TrafficLedgerDao(super.attachedDatabase);

  // ---------- 计费周期 ----------

  /// 获取当前活动周期（endAt 为 null）。若无则返回 null。
  Future<TrafficBillingPeriod?> getActivePeriod() {
    final q = trafficBillingPeriods.select()
      ..where((t) => t.endAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startAt)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  /// 获取所有周期，按开始时间倒序。
  Selectable<TrafficBillingPeriod> allPeriods() {
    final q = trafficBillingPeriods.select()
      ..orderBy([(t) => OrderingTerm.desc(t.startAt)]);
    return q;
  }

  /// 创建新周期并结束旧周期。返回新周期。
  /// 此操作即用户"新建计费周期"，与"清除全部历史"严格区分：
  /// 旧周期及其流量记录全部保留，仅设置 endAt。
  Future<TrafficBillingPeriod> startNewPeriod({
    String? label,
    DateTime? startAt,
    bool autoMonthSwitch = false,
  }) async {
    final now = DateTime.now();
    final start = startAt ?? now;
    return transaction(() async {
      // 结束当前活动周期。
      final active = await getActivePeriod();
      if (active != null) {
        await (trafficBillingPeriods.update()
              ..where((t) => t.id.equals(active.id)))
            .write(TrafficBillingPeriodsCompanion(endAt: Value(start.millisecondsSinceEpoch)));
      }
      final id = await into(trafficBillingPeriods).insert(
            TrafficBillingPeriodsCompanion.insert(
              label: Value(label),
              startAt: start.millisecondsSinceEpoch,
              autoMonthSwitch: Value(autoMonthSwitch),
              createdAt: now.millisecondsSinceEpoch,
            ),
          );
      return (trafficBillingPeriods.select()
            ..where((t) => t.id.equals(id)))
          .getSingle();
    });
  }

  /// 更新周期标签或自动月度开关。
  Future<void> updatePeriod(
    int id, {
    String? label,
    bool? autoMonthSwitch,
  }) async {
    final companion = TrafficBillingPeriodsCompanion(
      label: label != null ? Value(label) : const Value.absent(),
      autoMonthSwitch: autoMonthSwitch != null
          ? Value(autoMonthSwitch)
          : const Value.absent(),
    );
    await (trafficBillingPeriods.update()
          ..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// 若当前活动周期开启了 autoMonthSwitch 且已跨月，则自动结束旧周期并
  /// 按月初创建新周期。返回新创建的周期（若发生了切换），否则返回 null。
  Future<TrafficBillingPeriod?> maybeAutoMonthSwitch({
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final active = await getActivePeriod();
    if (active == null) return null;
    if (!active.autoMonthSwitch) return null;
    final start = DateTime.fromMillisecondsSinceEpoch(active.startAt);
    // 已跨月（年或月不同）则切换。
    if (start.year == moment.year && start.month == moment.month) {
      return null;
    }
    final monthStart = DateTime(moment.year, moment.month, 1);
    return startNewPeriod(
      label: active.label,
      startAt: monthStart,
      autoMonthSwitch: true,
    );
  }

  /// 清除全部 Traffic Ledger 历史（所有周期 + 所有小时聚合 + 所有节点倍率）。
  /// 与 [startNewPeriod] 严格区分：此操作删除一切历史。
  Future<void> clearAllHistory() async {
    await transaction(() async {
      // 先删小时聚合（外键 cascade 也会处理，但显式删更安全）。
      await trafficHourlyStats.delete().go();
      await trafficBillingPeriods.delete().go();
      await trafficNodeMultipliers.delete().go();
    });
  }

  // ---------- 小时聚合流量 ----------

  /// 批量 upsert 小时聚合记录。同主键记录累加 bytesUp/bytesDown，
  /// multiplier 保持首次写入值（历史不变性）。updatedAt 刷新为最新。
  /// 入参为 freezed model（DateTime），内部转换为 epoch millis 存储。
  Future<void> upsertHourlyStats(Iterable<HourlyTrafficStat> stats) async {
    if (stats.isEmpty) return;
    for (final s in stats) {
      final hourStartMs = s.hourStart.millisecondsSinceEpoch;
      final updatedAtMs = s.updatedAt.millisecondsSinceEpoch;
      final existing = await ((trafficHourlyStats.select()
            ..where((t) =>
                t.periodId.equals(s.periodId) &
                t.hourStart.equals(hourStartMs) &
                t.appIdentifier.equals(s.appIdentifier) &
                t.nodeName.equals(s.nodeName) &
                t.domain.equals(s.domain) &
                t.rule.equals(s.rule)))
          .getSingleOrNull());
      if (existing == null) {
        await into(trafficHourlyStats).insert(
          TrafficHourlyStatsCompanion.insert(
            periodId: s.periodId,
            hourStart: hourStartMs,
            appIdentifier: Value(s.appIdentifier),
            nodeName: Value(s.nodeName),
            domain: Value(s.domain),
            rule: Value(s.rule),
            bytesUp: Value(s.bytesUp),
            bytesDown: Value(s.bytesDown),
            multiplier: Value(s.multiplier),
            updatedAt: updatedAtMs,
          ),
        );
      } else {
        await (trafficHourlyStats.update()
              ..where((t) =>
                  t.periodId.equals(s.periodId) &
                  t.hourStart.equals(hourStartMs) &
                  t.appIdentifier.equals(s.appIdentifier) &
                  t.nodeName.equals(s.nodeName) &
                  t.domain.equals(s.domain) &
                  t.rule.equals(s.rule)))
            .write(TrafficHourlyStatsCompanion(
          bytesUp: Value(existing.bytesUp + s.bytesUp),
          bytesDown: Value(existing.bytesDown + s.bytesDown),
          updatedAt: Value(updatedAtMs),
        ));
      }
    }
  }

  /// 查询指定周期、时间范围 [from, to) 内的小时聚合记录。
  /// 返回 freezed model（DateTime），调用方无需关心 epoch millis。
  Selectable<HourlyTrafficStat> queryHourlyStats({
    required int periodId,
    DateTime? from,
    DateTime? to,
  }) {
    final q = trafficHourlyStats.select()
      ..where((t) => t.periodId.equals(periodId));
    if (from != null) {
      q.where((t) => t.hourStart.isBiggerOrEqualValue(from.millisecondsSinceEpoch));
    }
    if (to != null) {
      q.where((t) => t.hourStart.isSmallerThanValue(to.millisecondsSinceEpoch));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.hourStart)]);
    return q.map((row) => row.toModel());
  }

  // ---------- 节点倍率 ----------

  /// 获取节点倍率记录。若无则返回 null。
  Future<TrafficNodeMultiplier?> getNodeMultiplier(String nodeName) {
    final q = trafficNodeMultipliers.select()
      ..where((t) => t.nodeName.equals(nodeName))
      ..limit(1);
    return q.getSingleOrNull();
  }

  /// upsert 节点倍率。[parsedMultiplier] 来自自动解析，[manualMultiplier]
  /// 为用户手动覆盖（传 null 清除手动覆盖）。
  Future<void> upsertNodeMultiplier({
    required String nodeName,
    required double parsedMultiplier,
    double? manualMultiplier,
    DateTime? now,
  }) async {
    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch;
    await into(trafficNodeMultipliers).insertOnConflictUpdate(
          TrafficNodeMultipliersCompanion.insert(
            nodeName: nodeName,
            parsedMultiplier: Value(parsedMultiplier),
            manualMultiplier: manualMultiplier == null
                ? const Value.absent()
                : Value(manualMultiplier),
            updatedAt: ts,
          ),
        );
  }

  /// 设置或清除手动覆盖。传 null 清除手动覆盖（恢复自动解析值）。
  Future<void> setManualMultiplier({
    required String nodeName,
    double? manualMultiplier,
    DateTime? now,
  }) async {
    final existing = await getNodeMultiplier(nodeName);
    if (existing == null) {
      // 节点尚无记录，若清除手动覆盖则无需操作。
      if (manualMultiplier == null) return;
      await upsertNodeMultiplier(
        nodeName: nodeName,
        parsedMultiplier: 1.0,
        manualMultiplier: manualMultiplier,
        now: now,
      );
      return;
    }
    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch;
    await (trafficNodeMultipliers.update()
          ..where((t) => t.nodeName.equals(nodeName)))
        .write(TrafficNodeMultipliersCompanion(
      manualMultiplier: manualMultiplier == null
          ? const Value(null)
          : Value(manualMultiplier),
      updatedAt: Value(ts),
    ));
  }
}

extension RawTrafficBillingPeriodExt on TrafficBillingPeriod {
  BillingPeriod toModel() => BillingPeriod(
        id: id,
        label: label,
        startAt: DateTime.fromMillisecondsSinceEpoch(startAt),
        endAt: endAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(endAt!),
        autoMonthSwitch: autoMonthSwitch,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      );
}

extension RawTrafficHourlyStatExt on TrafficHourlyStat {
  HourlyTrafficStat toModel() => HourlyTrafficStat(
        periodId: periodId,
        hourStart: DateTime.fromMillisecondsSinceEpoch(hourStart),
        appIdentifier: appIdentifier,
        nodeName: nodeName,
        domain: domain,
        rule: rule,
        bytesUp: bytesUp,
        bytesDown: bytesDown,
        multiplier: multiplier,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      );
}

extension RawTrafficNodeMultiplierExt on TrafficNodeMultiplier {
  NodeMultiplier toModel() => NodeMultiplier(
        nodeName: nodeName,
        parsedMultiplier: parsedMultiplier,
        manualMultiplier: manualMultiplier,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      );
}

extension BillingPeriodCompanionExt on BillingPeriod {
  TrafficBillingPeriodsCompanion toCompanion() => TrafficBillingPeriodsCompanion(
        id: Value(id),
        label: Value(label),
        startAt: Value(startAt.millisecondsSinceEpoch),
        endAt: Value(endAt?.millisecondsSinceEpoch),
        autoMonthSwitch: Value(autoMonthSwitch),
        createdAt: Value(createdAt.millisecondsSinceEpoch),
      );
}
