import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/traffic_ledger.freezed.dart';
part 'generated/traffic_ledger.g.dart';

/// 计费周期状态。
enum BillingPeriodStatus {
  /// 当前活动周期（endAt 为 null）。
  active,

  /// 已结束的历史周期。
  closed,
}

/// 计费周期。当前活动周期跨代理开关、核心重启、应用重启持续累计；
/// 只有用户手动"新建计费周期"或开启自动月度切换时才会结束旧周期。
@freezed
abstract class BillingPeriod with _$BillingPeriod {
  const factory BillingPeriod({
    required int id,
    String? label,
    required DateTime startAt,
    DateTime? endAt,
    @Default(false) bool autoMonthSwitch,
    required DateTime createdAt,
  }) = _BillingPeriod;

  factory BillingPeriod.fromJson(Map<String, Object?> json) =>
      _$BillingPeriodFromJson(json);
}

extension BillingPeriodExt on BillingPeriod {
  BillingPeriodStatus get status =>
      endAt == null ? BillingPeriodStatus.active : BillingPeriodStatus.closed;

  bool get isActive => endAt == null;

  /// 该周期是否覆盖给定时刻（用于查询历史/当前周期归属）。
  bool covers(DateTime moment) {
    final start = startAt;
    if (moment.isBefore(start)) return false;
    final end = endAt;
    if (end != null && !moment.isBefore(end)) return false;
    return true;
  }
}

/// 按小时聚合的流量统计记录。长期只保存小时级聚合，不保存连接明细。
/// [multiplier] 是入账时的倍率快照，后续修改节点倍率不会回写历史。
@freezed
abstract class HourlyTrafficStat with _$HourlyTrafficStat {
  const factory HourlyTrafficStat({
    required int periodId,
    required DateTime hourStart,
    required String appIdentifier,
    required String nodeName,
    required String domain,
    required String rule,
    required int bytesUp,
    required int bytesDown,
    required double multiplier,
    required DateTime updatedAt,
  }) = _HourlyTrafficStat;

  factory HourlyTrafficStat.fromJson(Map<String, Object?> json) =>
      _$HourlyTrafficStatFromJson(json);
}

extension HourlyTrafficStatExt on HourlyTrafficStat {
  int get totalBytes => bytesUp + bytesDown;

  /// 按入账倍率计算的预计扣量（字节）。
  int get billedBytes => (totalBytes * multiplier).round();

  /// 是否为未归因代理流量（连接归因与总代理流量不一致时记录）。
  bool get isUnattributed => appIdentifier == unattributedAppIdentifier;
}

/// 节点倍率记录。[parsedMultiplier] 从节点名自动解析，[manualMultiplier]
/// 为用户手动覆盖。effective = manualMultiplier ?? parsedMultiplier。
/// 修改倍率只影响后续新写入的流量，不回写历史。
@freezed
abstract class NodeMultiplier with _$NodeMultiplier {
  const factory NodeMultiplier({
    required String nodeName,
    required double parsedMultiplier,
    double? manualMultiplier,
    required DateTime updatedAt,
  }) = _NodeMultiplier;

  factory NodeMultiplier.fromJson(Map<String, Object?> json) =>
      _$NodeMultiplierFromJson(json);
}

extension NodeMultiplierExt on NodeMultiplier {
  /// 生效倍率：手动覆盖优先，否则用自动解析值。
  double get effectiveMultiplier => manualMultiplier ?? parsedMultiplier;

  /// 是否被用户手动覆盖。
  bool get isManualOverridden => manualMultiplier != null;
}

/// 未归因代理流量的应用标识占位符。连接归因与总代理流量不一致时，
/// 差额以此标识写入，避免伪造精确的应用归因。
const String unattributedAppIdentifier = '__unattributed__';

/// 未知维度的占位符（应用/节点/域名/规则无法识别时使用）。
const String unknownDimensionValue = '';
