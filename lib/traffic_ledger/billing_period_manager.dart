import 'package:drift/drift.dart';
import 'package:fl_clash/database/database.dart';

/// 计费周期管理器。封装"当前活动周期持续累计"、"新建周期不清零历史"、
/// "清除全部历史与新建周期严格区分"、"可选月度自动切换"等业务逻辑。
///
/// 本类仅做业务编排，不直接持有定时器或监听核心状态。采集服务（Stage 3）
/// 会在 flush 时调用 [ensureActivePeriod] 获取当前周期 id。
class BillingPeriodManager {
  BillingPeriodManager(this._dao);

  final TrafficLedgerDao _dao;

  /// 获取当前活动周期。若无活动周期则自动创建一个（从现在开始）。
  /// 关键：代理开关、核心重启、应用重启都不会清零；只有此方法在无周期时
  /// 才会创建新周期，且创建时不删除任何历史。
  Future<TrafficBillingPeriod> ensureActivePeriod({DateTime? now}) async {
    final moment = now ?? DateTime.now();
    // 先尝试月度自动切换。
    await _dao.maybeAutoMonthSwitch(now: moment);
    final active = await _dao.getActivePeriod();
    if (active != null) return active;
    // 首次启动或历史被清除后，创建首个周期。
    return _dao.startNewPeriod(startAt: moment);
  }

  /// 用户手动"新建计费周期"。结束旧周期并创建新周期，保留所有历史。
  Future<TrafficBillingPeriod> createNewPeriod({
    String? label,
    DateTime? startAt,
    bool autoMonthSwitch = false,
  }) {
    return _dao.startNewPeriod(
      label: label,
      startAt: startAt,
      autoMonthSwitch: autoMonthSwitch,
    );
  }

  /// 清除全部 Traffic Ledger 历史。与 [createNewPeriod] 严格区分：
  /// 此操作删除所有周期、小时聚合和节点倍率记录。
  Future<void> clearAllHistory() => _dao.clearAllHistory();

  /// 更新周期标签或自动月度开关。
  Future<void> updatePeriod(
    int id, {
    String? label,
    bool? autoMonthSwitch,
  }) =>
      _dao.updatePeriod(
        id,
        label: label,
        autoMonthSwitch: autoMonthSwitch,
      );

  /// 获取所有周期（历史 + 当前），按开始时间倒序。
  Selectable<TrafficBillingPeriod> allPeriods() => _dao.allPeriods();

  /// 获取当前活动周期（可能为 null，若尚未初始化）。
  Future<TrafficBillingPeriod?> getActivePeriod() => _dao.getActivePeriod();
}
