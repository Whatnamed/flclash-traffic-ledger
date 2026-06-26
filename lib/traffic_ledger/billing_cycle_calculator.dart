import 'package:fl_clash/models/models.dart';

/// 计费周期刷新边界计算器。
///
/// 支持机场刷新日（1–28 日），不局限于自然月初。例如 billingCycleDay=25：
/// - 某月 25 日 00:00 到下月 25 日 00:00 为一个周期；
/// - 6-10 属于 5-25 起的周期；
/// - 6-25 00:00 起为新周期。
///
/// 限制 billingCycleDay ∈ [1, 28]，避免 29/30/31 日在短月份不存在的边界问题。
class BillingCycleCalculator {
  const BillingCycleCalculator._();

  /// 计算给定时刻所属周期的开始时间。
  /// 例：moment=6-10, billingCycleDay=25 → 返回 5-25 00:00。
  static DateTime cycleStartFor(DateTime moment, int billingCycleDay) {
    final day = billingCycleDay.clamp(1, 28);
    var year = moment.year;
    var month = moment.month;
    if (moment.day < day) {
      // 当前日 < 刷新日，周期从上月刷新日开始。
      month--;
      if (month < 1) {
        month = 12;
        year--;
      }
    }
    return DateTime(year, month, day);
  }

  /// 计算当前周期开始时间之后的下一个刷新边界。
  /// - currentStart=6-25, day=25 → 7-25（下月同日）。
  /// - currentStart=6-15, day=25 → 6-25（本月刷新日，因 6-25 > 6-15）。
  /// - currentStart=6-25 12:00, day=25 → 7-25（已过当日 00:00，取下月）。
  static DateTime nextCycleStart(
    DateTime currentStart,
    int billingCycleDay, [
    int billingCycleHour = 0,
  ]) {
    final day = billingCycleDay.clamp(1, 28);
    var candidate = DateTime(
      currentStart.year,
      currentStart.month,
      day,
      billingCycleHour,
    );
    if (!candidate.isAfter(currentStart)) {
      // candidate <= currentStart，取下个月。
      candidate = DateTime(
        currentStart.year,
        currentStart.month + 1,
        day,
        billingCycleHour,
      );
    }
    return candidate;
  }

  /// 校验 [LedgerSettings] 的刷新日是否合法。
  static bool isValid(LedgerSettings settings) => settings.isValidCycleDay;
}
