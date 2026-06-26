part of 'database.dart';

/// 计费周期表。当前活动周期 endAt 为 null；用户手动"新建计费周期"或
/// 自动周期切换触发时结束旧周期（设置 endAt）并创建新周期。
///
/// 自动周期配置（刷新日、开关）存放在 [TrafficLedgerSettings]，
/// 不再绑定到单个周期。
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

  IntColumn get createdAt => integer()();
}

/// 按小时聚合的流量统计表。长期只保存小时级聚合，不保存连接明细。
/// 组合主键：(periodId, hourStart, appIdentifier, nodeName, domain, rule)。
///
/// [multiplier] 仅作展示用途（首次入账倍率快照）。
/// [estimatedBilledBytesUp] / [estimatedBilledBytesDown] 在入账时按
/// "本次增量 × 当时有效倍率"累计，后续修改节点倍率不回写历史。
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

  /// 首次入账时倍率快照，仅用于展示。
  RealColumn get multiplier => real().withDefault(const Constant(1.0))();

  /// 入账时按"本次增量上行 × 当时有效倍率"累计的预计扣量。
  IntColumn get estimatedBilledBytesUp =>
      integer().withDefault(const Constant(0))();

  /// 入账时按"本次增量下行 × 当时有效倍率"累计的预计扣量。
  IntColumn get estimatedBilledBytesDown =>
      integer().withDefault(const Constant(0))();

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

/// 流量账本全局设置表（单行表，id 固定为 1）。
/// 存放自动周期配置等账本级设置，不依附于某个历史周期。
@DataClassName('TrafficLedgerSetting')
class TrafficLedgerSettings extends Table {
  @override
  String get tableName => 'traffic_ledger_settings';

  /// 固定为 1，保证全局唯一一行。
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// 是否启用自动周期切换。
  BoolColumn get autoCycleEnabled =>
      boolean().withDefault(const Constant(false))();

  /// 每月刷新日，取值范围 1–28。
  IntColumn get billingCycleDay =>
      integer().withDefault(const Constant(1))();

  /// 刷新小时。第一版固定为 0（00:00），预留。
  IntColumn get billingCycleHour =>
      integer().withDefault(const Constant(0))();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [
  TrafficBillingPeriods,
  TrafficHourlyStats,
  TrafficNodeMultipliers,
  TrafficLedgerSettings,
])
class TrafficLedgerDao extends DatabaseAccessor<Database>
    with _$TrafficLedgerDaoMixin {
  TrafficLedgerDao(super.attachedDatabase);

  // ---------- 账本设置 ----------

  /// 获取账本设置。若无记录则返回默认值（不写库）。
  Future<LedgerSettings> getSettings() async {
    final row = await (trafficLedgerSettings.select()
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return defaultLedgerSettings;
    return row.toModel();
  }

  /// 更新账本设置（upsert id=1）。
  Future<void> updateSettings(LedgerSettings settings, {DateTime? now}) async {
    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch;
    await trafficLedgerSettings.insertOnConflictUpdate(
      TrafficLedgerSettingsCompanion.insert(
        id: const Value(1),
        autoCycleEnabled: Value(settings.autoCycleEnabled),
        billingCycleDay: Value(settings.billingCycleDay),
        billingCycleHour: Value(settings.billingCycleHour),
        updatedAt: ts,
      ),
    );
  }

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
  /// 此操作即用户"新建计费周期"，与"清除流量历史"严格区分：
  /// 旧周期及其流量记录全部保留，仅设置 endAt。
  Future<TrafficBillingPeriod> startNewPeriod({
    String? label,
    DateTime? startAt,
  }) async {
    final now = DateTime.now();
    final start = startAt ?? now;
    return transaction(() async {
      // 结束当前活动周期。
      final active = await getActivePeriod();
      if (active != null) {
        await (trafficBillingPeriods.update()
              ..where((t) => t.id.equals(active.id)))
            .write(TrafficBillingPeriodsCompanion(
                endAt: Value(start.millisecondsSinceEpoch)));
      }
      final id = await into(trafficBillingPeriods).insert(
            TrafficBillingPeriodsCompanion.insert(
              label: Value(label),
              startAt: start.millisecondsSinceEpoch,
              createdAt: now.millisecondsSinceEpoch,
            ),
          );
      return (trafficBillingPeriods.select()
            ..where((t) => t.id.equals(id)))
          .getSingle();
    });
  }

  /// 更新周期标签。
  Future<void> updatePeriod(int id, {String? label}) async {
    final companion = TrafficBillingPeriodsCompanion(
      label: label != null ? Value(label) : const Value.absent(),
    );
    await (trafficBillingPeriods.update()
          ..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// 若账本设置开启自动周期且当前时刻已跨过刷新边界，则结束旧周期并
  /// 创建新周期。返回新创建的周期（若发生了切换），否则 null。
  ///
  /// 多边界追赶语义（Stage 2.3 修正）：
  /// - 旧活动周期在它遇到的**第一个真实刷新边界**结束，不为了消灭空档
  ///   而跨越已错过的真实刷新边界；
  /// - 中间错过的空周期不创建（允许历史时间线上存在"未采集/未运行"空档）；
  /// - 新活动周期从当前时刻所属周期开始（cycleStartFor(now)）；
  /// - 不允许重叠，新周期 startAt = currentCycleStart；
  /// - 整个"结束旧周期 + 创建当前周期"在一个数据库事务中执行；
  /// - 重复调用幂等：若活动周期已对齐当前所属周期，不再创建。
  ///
  /// 应用未运行时不执行；下次 ensureActivePeriod 时会补做切换。
  Future<TrafficBillingPeriod?> maybeAutoCycleSwitch({
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final settings = await getSettings();
    if (!settings.autoCycleEnabled) return null;
    final active = await getActivePeriod();
    if (active == null) return null;
    final currentStart =
        DateTime.fromMillisecondsSinceEpoch(active.startAt);
    // 当前时刻所属周期的开始时间。
    final currentCycleStart = BillingCycleCalculator.cycleStartFor(
      moment,
      settings.billingCycleDay,
    );
    // 若当前周期开始时间不晚于旧周期开始时间，则仍在旧周期内，无需切换。
    if (!currentCycleStart.isAfter(currentStart)) return null;
    // 旧周期遇到的第一个真实刷新边界。
    final firstMissedBoundary = BillingCycleCalculator.nextCycleStart(
      currentStart,
      settings.billingCycleDay,
      settings.billingCycleHour,
    );
    return transaction(() async {
      // 1. 旧周期结束于它遇到的第一个真实刷新边界（而非 currentCycleStart）。
      await (trafficBillingPeriods.update()
            ..where((t) => t.id.equals(active.id)))
          .write(TrafficBillingPeriodsCompanion(
              endAt: Value(firstMissedBoundary.millisecondsSinceEpoch)));
      // 2. 不创建 firstMissedBoundary 到 currentCycleStart 之间的空周期。
      // 3. 创建新活动周期，startAt = currentCycleStart。
      final id = await into(trafficBillingPeriods).insert(
            TrafficBillingPeriodsCompanion.insert(
              label: Value(active.label),
              startAt: currentCycleStart.millisecondsSinceEpoch,
              createdAt: moment.millisecondsSinceEpoch,
            ),
          );
      return (trafficBillingPeriods.select()
            ..where((t) => t.id.equals(id)))
          .getSingle();
    });
  }

  /// 清除流量历史：删除所有周期和小时聚合记录，**保留**节点倍率手动覆盖
  /// 和账本设置。与 [startNewPeriod]（保留历史）和 [resetLedgerSettings]
  /// （删倍率+重置设置）严格区分。
  Future<void> clearTrafficHistory() async {
    await transaction(() async {
      // 先删小时聚合（外键 cascade 也会处理，但显式删更安全）。
      await trafficHourlyStats.delete().go();
      await trafficBillingPeriods.delete().go();
    });
  }

  /// 重置流量账本设置：删除节点倍率手动覆盖，并将账本设置恢复默认。
  /// 不会删除周期和流量统计（那是 [clearTrafficHistory] 的职责）。
  Future<void> resetLedgerSettings({DateTime? now}) async {
    await transaction(() async {
      await trafficNodeMultipliers.delete().go();
      await (trafficLedgerSettings.delete()
            ..where((t) => t.id.equals(1)))
          .go();
    });
  }

  // ---------- 小时聚合流量 ----------

  /// 批量 upsert 小时聚合记录。同主键记录累加 bytesUp/bytesDown 与
  /// estimatedBilledBytesUp/estimatedBilledBytesDown。
  /// multiplier 保持首次写入值（展示用途）。updatedAt 刷新为最新。
  /// 入参为 freezed model（DateTime），内部转换为 epoch millis 存储。
  ///
  /// 调用方（采集服务）负责在构造 [HourlyTrafficStat] 时按
  /// "本次增量 × 当时有效倍率"计算 estimatedBilledBytes*。
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
            estimatedBilledBytesUp: Value(s.estimatedBilledBytesUp),
            estimatedBilledBytesDown: Value(s.estimatedBilledBytesDown),
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
          estimatedBilledBytesUp: Value(
              existing.estimatedBilledBytesUp + s.estimatedBilledBytesUp),
          estimatedBilledBytesDown: Value(
              existing.estimatedBilledBytesDown +
                  s.estimatedBilledBytesDown),
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
      q.where(
          (t) => t.hourStart.isBiggerOrEqualValue(from.millisecondsSinceEpoch));
    }
    if (to != null) {
      q.where((t) =>
          t.hourStart.isSmallerThanValue(to.millisecondsSinceEpoch));
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
        estimatedBilledBytesUp: estimatedBilledBytesUp,
        estimatedBilledBytesDown: estimatedBilledBytesDown,
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

extension RawTrafficLedgerSettingExt on TrafficLedgerSetting {
  LedgerSettings toModel() => LedgerSettings(
        autoCycleEnabled: autoCycleEnabled,
        billingCycleDay: billingCycleDay,
        billingCycleHour: billingCycleHour,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      );
}

extension BillingPeriodCompanionExt on BillingPeriod {
  TrafficBillingPeriodsCompanion toCompanion() => TrafficBillingPeriodsCompanion(
        id: Value(id),
        label: Value(label),
        startAt: Value(startAt.millisecondsSinceEpoch),
        endAt: Value(endAt?.millisecondsSinceEpoch),
        createdAt: Value(createdAt.millisecondsSinceEpoch),
      );
}
