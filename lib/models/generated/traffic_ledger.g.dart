// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../traffic_ledger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingPeriod _$BillingPeriodFromJson(Map<String, dynamic> json) =>
    _BillingPeriod(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String?,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null
          ? null
          : DateTime.parse(json['endAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BillingPeriodToJson(_BillingPeriod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_HourlyTrafficStat _$HourlyTrafficStatFromJson(Map<String, dynamic> json) =>
    _HourlyTrafficStat(
      periodId: (json['periodId'] as num).toInt(),
      hourStart: DateTime.parse(json['hourStart'] as String),
      appIdentifier: json['appIdentifier'] as String,
      nodeName: json['nodeName'] as String,
      domain: json['domain'] as String,
      rule: json['rule'] as String,
      bytesUp: (json['bytesUp'] as num).toInt(),
      bytesDown: (json['bytesDown'] as num).toInt(),
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      estimatedBilledBytesUp:
          (json['estimatedBilledBytesUp'] as num?)?.toInt() ?? 0,
      estimatedBilledBytesDown:
          (json['estimatedBilledBytesDown'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$HourlyTrafficStatToJson(_HourlyTrafficStat instance) =>
    <String, dynamic>{
      'periodId': instance.periodId,
      'hourStart': instance.hourStart.toIso8601String(),
      'appIdentifier': instance.appIdentifier,
      'nodeName': instance.nodeName,
      'domain': instance.domain,
      'rule': instance.rule,
      'bytesUp': instance.bytesUp,
      'bytesDown': instance.bytesDown,
      'multiplier': instance.multiplier,
      'estimatedBilledBytesUp': instance.estimatedBilledBytesUp,
      'estimatedBilledBytesDown': instance.estimatedBilledBytesDown,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_NodeMultiplier _$NodeMultiplierFromJson(Map<String, dynamic> json) =>
    _NodeMultiplier(
      nodeName: json['nodeName'] as String,
      parsedMultiplier: (json['parsedMultiplier'] as num).toDouble(),
      manualMultiplier: (json['manualMultiplier'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NodeMultiplierToJson(_NodeMultiplier instance) =>
    <String, dynamic>{
      'nodeName': instance.nodeName,
      'parsedMultiplier': instance.parsedMultiplier,
      'manualMultiplier': instance.manualMultiplier,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_LedgerSettings _$LedgerSettingsFromJson(Map<String, dynamic> json) =>
    _LedgerSettings(
      autoCycleEnabled: json['autoCycleEnabled'] as bool? ?? false,
      billingCycleDay: (json['billingCycleDay'] as num?)?.toInt() ?? 1,
      billingCycleHour: (json['billingCycleHour'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LedgerSettingsToJson(_LedgerSettings instance) =>
    <String, dynamic>{
      'autoCycleEnabled': instance.autoCycleEnabled,
      'billingCycleDay': instance.billingCycleDay,
      'billingCycleHour': instance.billingCycleHour,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
