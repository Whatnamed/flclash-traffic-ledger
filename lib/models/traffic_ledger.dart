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
/// 只有用户手动"新建计费周期"或开启自动周期切换时才会结束旧周期。
///
/// 自动周期配置（刷新日、开关）存放在 [LedgerSettings]，不再绑定到
/// 单个周期。本模型仅保留周期自身的时间范围与标签，用于历史追溯。
@freezed
abstract class BillingPeriod with _$BillingPeriod {
  const factory BillingPeriod({
    required int id,
    String? label,
    required DateTime startAt,
    DateTime? endAt,
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
///
/// 预计扣量由 [estimatedBilledBytesUp] / [estimatedBilledBytesDown] 在入账时
/// 按"本次增量 × 当时有效倍率"累计，后续修改节点倍率不会回写历史。
/// [multiplier] 仅作展示用途（首次入账倍率快照），不再承担预计扣量计算。
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
    /// 首次入账时的倍率快照，仅用于展示。
    @Default(1.0) double multiplier,
    /// 入账时按"本次增量 × 当时有效倍率"累计的预计扣量（上行）。
    @Default(0) int estimatedBilledBytesUp,
    /// 入账时按"本次增量 × 当时有效倍率"累计的预计扣量（下行）。
    @Default(0) int estimatedBilledBytesDown,
    required DateTime updatedAt,
  }) = _HourlyTrafficStat;

  factory HourlyTrafficStat.fromJson(Map<String, Object?> json) =>
      _$HourlyTrafficStatFromJson(json);
}

extension HourlyTrafficStatExt on HourlyTrafficStat {
  int get totalBytes => bytesUp + bytesDown;

  /// 按入账时累计的预计扣量（字节）。
  /// 不允许再用 totalBytes × multiplier 重算。
  int get billedBytes => estimatedBilledBytesUp + estimatedBilledBytesDown;

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

/// 流量账本全局设置（单行表，id 固定为 1）。
/// 自动周期配置属于账本设置，不依附于某个历史周期。
@freezed
abstract class LedgerSettings with _$LedgerSettings {
  const factory LedgerSettings({
    /// 是否启用自动周期切换。默认关闭。
    @Default(false) bool autoCycleEnabled,
    /// 每月刷新日，取值范围 1–28。默认 1（等价于自然月初）。
    @Default(1) int billingCycleDay,
    /// 刷新小时。第一版固定为 0（00:00），预留字段以便后续支持自定义时刻。
    @Default(0) int billingCycleHour,
    DateTime? updatedAt,
  }) = _LedgerSettings;

  factory LedgerSettings.fromJson(Map<String, Object?> json) =>
      _$LedgerSettingsFromJson(json);
}

extension LedgerSettingsExt on LedgerSettings {
  /// 校验刷新日是否在合法范围 [1, 28]。
  bool get isValidCycleDay => billingCycleDay >= 1 && billingCycleDay <= 28;
}

/// 流量账本设置的默认值（关闭自动周期，刷新日为 1）。
const LedgerSettings defaultLedgerSettings = LedgerSettings();

/// 未归因代理流量的应用标识占位符。连接归因与总代理流量不一致时，
/// 差额以此标识写入，避免伪造精确的应用归因。
const String unattributedAppIdentifier = '__unattributed__';

/// 未知维度的占位符（应用/节点/域名/规则无法识别时使用）。
const String unknownDimensionValue = '';
