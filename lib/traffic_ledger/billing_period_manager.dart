import 'package:drift/drift.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_cycle_calculator.dart';

/// 计费周期管理器。封装"当前活动周期持续累计"、"新建周期不清零历史"、
/// "清除流量历史与新建周期严格区分"、"可选自动周期切换（支持机场刷新日）"
/// 等业务逻辑。
///
/// 本类仅做业务编排，不直接持有定时器或监听核心状态。采集服务（Stage 3）
/// 会在 flush 时调用 [ensureActivePeriod] 获取当前周期 id。
class BillingPeriodManager {
  BillingPeriodManager(this._dao);

  final TrafficLedgerDao _dao;

  /// 获取当前活动周期。若无活动周期则自动创建一个。
  ///
  /// 创建首个周期的 startAt 规则：
  /// - 自动周期开启：从 cycleStartFor(now, billingCycleDay) 开始
  ///   （当前时刻所属周期的开始时间）；
  /// - 自动周期关闭：从当前时刻开始。
  ///
  /// 关键：代理开关、核心重启、应用重启都不会清零；只有此方法在无周期时
  /// 才会创建新周期，且创建时不删除任何历史。
  ///
  /// 若账本设置开启自动周期且当前时刻已跨过刷新边界（含跨多个边界的追赶），
  /// 会先补做周期切换。
  Future<TrafficBillingPeriod> ensureActivePeriod({DateTime? now}) async {
    final moment = now ?? DateTime.now();
    // 先尝试自动周期切换（基于 settings 的刷新日，含多边界追赶）。
    await _dao.maybeAutoCycleSwitch(now: moment);
    final active = await _dao.getActivePeriod();
    if (active != null) return active;
    // 首次启动或历史被清除后，创建首个周期。
    final settings = await _dao.getSettings();
    final startAt = settings.autoCycleEnabled
        ? BillingCycleCalculator.cycleStartFor(
            moment,
            settings.billingCycleDay,
          )
        : moment;
    return _dao.startNewPeriod(startAt: startAt);
  }

  /// 用户手动"新建计费周期"。结束旧周期并创建新周期，保留所有历史。
  /// 不受自动周期逻辑影响，始终从用户点击时刻开始（未传 startAt 时用 now）。
  Future<TrafficBillingPeriod> createNewPeriod({
    String? label,
    DateTime? startAt,
  }) {
    return _dao.startNewPeriod(
      label: label,
      startAt: startAt,
    );
  }

  /// 清除流量历史：删除所有周期和小时聚合记录，**保留**节点倍率手动覆盖
  /// 和账本设置。与 [createNewPeriod]（保留历史）严格区分。
  Future<void> clearTrafficHistory() => _dao.clearTrafficHistory();

  /// 重置流量账本设置：删除节点倍率手动覆盖，并将账本设置恢复默认。
  /// 不会删除周期和流量统计。
  Future<void> resetLedgerSettings() => _dao.resetLedgerSettings();

  /// 更新周期标签。
  Future<void> updatePeriod(int id, {String? label}) =>
      _dao.updatePeriod(id, label: label);

  /// 获取账本设置。若无记录则返回默认值。
  Future<LedgerSettings> getSettings() => _dao.getSettings();

  /// 更新账本设置（自动周期开关、刷新日等）。
  Future<void> updateSettings(LedgerSettings settings, {DateTime? now}) =>
      _dao.updateSettings(settings, now: now);

  /// 批量 upsert 小时聚合记录。委托到 [TrafficLedgerDao.upsertHourlyStats]。
  /// 采集服务 flush 时调用。
  Future<void> upsertHourlyStats(Iterable<HourlyTrafficStat> stats) =>
      _dao.upsertHourlyStats(stats);

  /// 获取所有周期（历史 + 当前），按开始时间倒序。
  Selectable<TrafficBillingPeriod> allPeriods() => _dao.allPeriods();

  /// 获取当前活动周期（可能为 null，若尚未初始化）。
  Future<TrafficBillingPeriod?> getActivePeriod() => _dao.getActivePeriod();
}
