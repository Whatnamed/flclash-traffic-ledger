// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../traffic_ledger.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillingPeriod {

 int get id; String? get label; DateTime get startAt; DateTime? get endAt; DateTime get createdAt;
/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingPeriodCopyWith<BillingPeriod> get copyWith => _$BillingPeriodCopyWithImpl<BillingPeriod>(this as BillingPeriod, _$identity);

  /// Serializes this BillingPeriod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingPeriod&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,startAt,endAt,createdAt);

@override
String toString() {
  return 'BillingPeriod(id: $id, label: $label, startAt: $startAt, endAt: $endAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BillingPeriodCopyWith<$Res>  {
  factory $BillingPeriodCopyWith(BillingPeriod value, $Res Function(BillingPeriod) _then) = _$BillingPeriodCopyWithImpl;
@useResult
$Res call({
 int id, String? label, DateTime startAt, DateTime? endAt, DateTime createdAt
});




}
/// @nodoc
class _$BillingPeriodCopyWithImpl<$Res>
    implements $BillingPeriodCopyWith<$Res> {
  _$BillingPeriodCopyWithImpl(this._self, this._then);

  final BillingPeriod _self;
  final $Res Function(BillingPeriod) _then;

/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? startAt = null,Object? endAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingPeriod].
extension BillingPeriodPatterns on BillingPeriod {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingPeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingPeriod value)  $default,){
final _that = this;
switch (_that) {
case _BillingPeriod():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingPeriod value)?  $default,){
final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? label,  DateTime startAt,  DateTime? endAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
return $default(_that.id,_that.label,_that.startAt,_that.endAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? label,  DateTime startAt,  DateTime? endAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BillingPeriod():
return $default(_that.id,_that.label,_that.startAt,_that.endAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? label,  DateTime startAt,  DateTime? endAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
return $default(_that.id,_that.label,_that.startAt,_that.endAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingPeriod implements BillingPeriod {
  const _BillingPeriod({required this.id, this.label, required this.startAt, this.endAt, required this.createdAt});
  factory _BillingPeriod.fromJson(Map<String, dynamic> json) => _$BillingPeriodFromJson(json);

@override final  int id;
@override final  String? label;
@override final  DateTime startAt;
@override final  DateTime? endAt;
@override final  DateTime createdAt;

/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingPeriodCopyWith<_BillingPeriod> get copyWith => __$BillingPeriodCopyWithImpl<_BillingPeriod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingPeriodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingPeriod&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,startAt,endAt,createdAt);

@override
String toString() {
  return 'BillingPeriod(id: $id, label: $label, startAt: $startAt, endAt: $endAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BillingPeriodCopyWith<$Res> implements $BillingPeriodCopyWith<$Res> {
  factory _$BillingPeriodCopyWith(_BillingPeriod value, $Res Function(_BillingPeriod) _then) = __$BillingPeriodCopyWithImpl;
@override @useResult
$Res call({
 int id, String? label, DateTime startAt, DateTime? endAt, DateTime createdAt
});




}
/// @nodoc
class __$BillingPeriodCopyWithImpl<$Res>
    implements _$BillingPeriodCopyWith<$Res> {
  __$BillingPeriodCopyWithImpl(this._self, this._then);

  final _BillingPeriod _self;
  final $Res Function(_BillingPeriod) _then;

/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? startAt = null,Object? endAt = freezed,Object? createdAt = null,}) {
  return _then(_BillingPeriod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$HourlyTrafficStat {

 int get periodId; DateTime get hourStart; String get appIdentifier; String get nodeName; String get domain; String get rule; int get bytesUp; int get bytesDown;/// 首次入账时的倍率快照，仅用于展示。
 double get multiplier;/// 入账时按"本次增量 × 当时有效倍率"累计的预计扣量（上行）。
 int get estimatedBilledBytesUp;/// 入账时按"本次增量 × 当时有效倍率"累计的预计扣量（下行）。
 int get estimatedBilledBytesDown; DateTime get updatedAt;
/// Create a copy of HourlyTrafficStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HourlyTrafficStatCopyWith<HourlyTrafficStat> get copyWith => _$HourlyTrafficStatCopyWithImpl<HourlyTrafficStat>(this as HourlyTrafficStat, _$identity);

  /// Serializes this HourlyTrafficStat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HourlyTrafficStat&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.hourStart, hourStart) || other.hourStart == hourStart)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&(identical(other.nodeName, nodeName) || other.nodeName == nodeName)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.bytesUp, bytesUp) || other.bytesUp == bytesUp)&&(identical(other.bytesDown, bytesDown) || other.bytesDown == bytesDown)&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier)&&(identical(other.estimatedBilledBytesUp, estimatedBilledBytesUp) || other.estimatedBilledBytesUp == estimatedBilledBytesUp)&&(identical(other.estimatedBilledBytesDown, estimatedBilledBytesDown) || other.estimatedBilledBytesDown == estimatedBilledBytesDown)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodId,hourStart,appIdentifier,nodeName,domain,rule,bytesUp,bytesDown,multiplier,estimatedBilledBytesUp,estimatedBilledBytesDown,updatedAt);

@override
String toString() {
  return 'HourlyTrafficStat(periodId: $periodId, hourStart: $hourStart, appIdentifier: $appIdentifier, nodeName: $nodeName, domain: $domain, rule: $rule, bytesUp: $bytesUp, bytesDown: $bytesDown, multiplier: $multiplier, estimatedBilledBytesUp: $estimatedBilledBytesUp, estimatedBilledBytesDown: $estimatedBilledBytesDown, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HourlyTrafficStatCopyWith<$Res>  {
  factory $HourlyTrafficStatCopyWith(HourlyTrafficStat value, $Res Function(HourlyTrafficStat) _then) = _$HourlyTrafficStatCopyWithImpl;
@useResult
$Res call({
 int periodId, DateTime hourStart, String appIdentifier, String nodeName, String domain, String rule, int bytesUp, int bytesDown, double multiplier, int estimatedBilledBytesUp, int estimatedBilledBytesDown, DateTime updatedAt
});




}
/// @nodoc
class _$HourlyTrafficStatCopyWithImpl<$Res>
    implements $HourlyTrafficStatCopyWith<$Res> {
  _$HourlyTrafficStatCopyWithImpl(this._self, this._then);

  final HourlyTrafficStat _self;
  final $Res Function(HourlyTrafficStat) _then;

/// Create a copy of HourlyTrafficStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodId = null,Object? hourStart = null,Object? appIdentifier = null,Object? nodeName = null,Object? domain = null,Object? rule = null,Object? bytesUp = null,Object? bytesDown = null,Object? multiplier = null,Object? estimatedBilledBytesUp = null,Object? estimatedBilledBytesDown = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as int,hourStart: null == hourStart ? _self.hourStart : hourStart // ignore: cast_nullable_to_non_nullable
as DateTime,appIdentifier: null == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String,nodeName: null == nodeName ? _self.nodeName : nodeName // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,bytesUp: null == bytesUp ? _self.bytesUp : bytesUp // ignore: cast_nullable_to_non_nullable
as int,bytesDown: null == bytesDown ? _self.bytesDown : bytesDown // ignore: cast_nullable_to_non_nullable
as int,multiplier: null == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double,estimatedBilledBytesUp: null == estimatedBilledBytesUp ? _self.estimatedBilledBytesUp : estimatedBilledBytesUp // ignore: cast_nullable_to_non_nullable
as int,estimatedBilledBytesDown: null == estimatedBilledBytesDown ? _self.estimatedBilledBytesDown : estimatedBilledBytesDown // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HourlyTrafficStat].
extension HourlyTrafficStatPatterns on HourlyTrafficStat {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HourlyTrafficStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HourlyTrafficStat() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HourlyTrafficStat value)  $default,){
final _that = this;
switch (_that) {
case _HourlyTrafficStat():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HourlyTrafficStat value)?  $default,){
final _that = this;
switch (_that) {
case _HourlyTrafficStat() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int periodId,  DateTime hourStart,  String appIdentifier,  String nodeName,  String domain,  String rule,  int bytesUp,  int bytesDown,  double multiplier,  int estimatedBilledBytesUp,  int estimatedBilledBytesDown,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HourlyTrafficStat() when $default != null:
return $default(_that.periodId,_that.hourStart,_that.appIdentifier,_that.nodeName,_that.domain,_that.rule,_that.bytesUp,_that.bytesDown,_that.multiplier,_that.estimatedBilledBytesUp,_that.estimatedBilledBytesDown,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int periodId,  DateTime hourStart,  String appIdentifier,  String nodeName,  String domain,  String rule,  int bytesUp,  int bytesDown,  double multiplier,  int estimatedBilledBytesUp,  int estimatedBilledBytesDown,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HourlyTrafficStat():
return $default(_that.periodId,_that.hourStart,_that.appIdentifier,_that.nodeName,_that.domain,_that.rule,_that.bytesUp,_that.bytesDown,_that.multiplier,_that.estimatedBilledBytesUp,_that.estimatedBilledBytesDown,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int periodId,  DateTime hourStart,  String appIdentifier,  String nodeName,  String domain,  String rule,  int bytesUp,  int bytesDown,  double multiplier,  int estimatedBilledBytesUp,  int estimatedBilledBytesDown,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HourlyTrafficStat() when $default != null:
return $default(_that.periodId,_that.hourStart,_that.appIdentifier,_that.nodeName,_that.domain,_that.rule,_that.bytesUp,_that.bytesDown,_that.multiplier,_that.estimatedBilledBytesUp,_that.estimatedBilledBytesDown,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HourlyTrafficStat implements HourlyTrafficStat {
  const _HourlyTrafficStat({required this.periodId, required this.hourStart, required this.appIdentifier, required this.nodeName, required this.domain, required this.rule, required this.bytesUp, required this.bytesDown, this.multiplier = 1.0, this.estimatedBilledBytesUp = 0, this.estimatedBilledBytesDown = 0, required this.updatedAt});
  factory _HourlyTrafficStat.fromJson(Map<String, dynamic> json) => _$HourlyTrafficStatFromJson(json);

@override final  int periodId;
@override final  DateTime hourStart;
@override final  String appIdentifier;
@override final  String nodeName;
@override final  String domain;
@override final  String rule;
@override final  int bytesUp;
@override final  int bytesDown;
/// 首次入账时的倍率快照，仅用于展示。
@override@JsonKey() final  double multiplier;
/// 入账时按"本次增量 × 当时有效倍率"累计的预计扣量（上行）。
@override@JsonKey() final  int estimatedBilledBytesUp;
/// 入账时按"本次增量 × 当时有效倍率"累计的预计扣量（下行）。
@override@JsonKey() final  int estimatedBilledBytesDown;
@override final  DateTime updatedAt;

/// Create a copy of HourlyTrafficStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HourlyTrafficStatCopyWith<_HourlyTrafficStat> get copyWith => __$HourlyTrafficStatCopyWithImpl<_HourlyTrafficStat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HourlyTrafficStatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HourlyTrafficStat&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.hourStart, hourStart) || other.hourStart == hourStart)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&(identical(other.nodeName, nodeName) || other.nodeName == nodeName)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.bytesUp, bytesUp) || other.bytesUp == bytesUp)&&(identical(other.bytesDown, bytesDown) || other.bytesDown == bytesDown)&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier)&&(identical(other.estimatedBilledBytesUp, estimatedBilledBytesUp) || other.estimatedBilledBytesUp == estimatedBilledBytesUp)&&(identical(other.estimatedBilledBytesDown, estimatedBilledBytesDown) || other.estimatedBilledBytesDown == estimatedBilledBytesDown)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodId,hourStart,appIdentifier,nodeName,domain,rule,bytesUp,bytesDown,multiplier,estimatedBilledBytesUp,estimatedBilledBytesDown,updatedAt);

@override
String toString() {
  return 'HourlyTrafficStat(periodId: $periodId, hourStart: $hourStart, appIdentifier: $appIdentifier, nodeName: $nodeName, domain: $domain, rule: $rule, bytesUp: $bytesUp, bytesDown: $bytesDown, multiplier: $multiplier, estimatedBilledBytesUp: $estimatedBilledBytesUp, estimatedBilledBytesDown: $estimatedBilledBytesDown, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HourlyTrafficStatCopyWith<$Res> implements $HourlyTrafficStatCopyWith<$Res> {
  factory _$HourlyTrafficStatCopyWith(_HourlyTrafficStat value, $Res Function(_HourlyTrafficStat) _then) = __$HourlyTrafficStatCopyWithImpl;
@override @useResult
$Res call({
 int periodId, DateTime hourStart, String appIdentifier, String nodeName, String domain, String rule, int bytesUp, int bytesDown, double multiplier, int estimatedBilledBytesUp, int estimatedBilledBytesDown, DateTime updatedAt
});




}
/// @nodoc
class __$HourlyTrafficStatCopyWithImpl<$Res>
    implements _$HourlyTrafficStatCopyWith<$Res> {
  __$HourlyTrafficStatCopyWithImpl(this._self, this._then);

  final _HourlyTrafficStat _self;
  final $Res Function(_HourlyTrafficStat) _then;

/// Create a copy of HourlyTrafficStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodId = null,Object? hourStart = null,Object? appIdentifier = null,Object? nodeName = null,Object? domain = null,Object? rule = null,Object? bytesUp = null,Object? bytesDown = null,Object? multiplier = null,Object? estimatedBilledBytesUp = null,Object? estimatedBilledBytesDown = null,Object? updatedAt = null,}) {
  return _then(_HourlyTrafficStat(
periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as int,hourStart: null == hourStart ? _self.hourStart : hourStart // ignore: cast_nullable_to_non_nullable
as DateTime,appIdentifier: null == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String,nodeName: null == nodeName ? _self.nodeName : nodeName // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,bytesUp: null == bytesUp ? _self.bytesUp : bytesUp // ignore: cast_nullable_to_non_nullable
as int,bytesDown: null == bytesDown ? _self.bytesDown : bytesDown // ignore: cast_nullable_to_non_nullable
as int,multiplier: null == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double,estimatedBilledBytesUp: null == estimatedBilledBytesUp ? _self.estimatedBilledBytesUp : estimatedBilledBytesUp // ignore: cast_nullable_to_non_nullable
as int,estimatedBilledBytesDown: null == estimatedBilledBytesDown ? _self.estimatedBilledBytesDown : estimatedBilledBytesDown // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$NodeMultiplier {

 String get nodeName; double get parsedMultiplier; double? get manualMultiplier; DateTime get updatedAt;
/// Create a copy of NodeMultiplier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NodeMultiplierCopyWith<NodeMultiplier> get copyWith => _$NodeMultiplierCopyWithImpl<NodeMultiplier>(this as NodeMultiplier, _$identity);

  /// Serializes this NodeMultiplier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NodeMultiplier&&(identical(other.nodeName, nodeName) || other.nodeName == nodeName)&&(identical(other.parsedMultiplier, parsedMultiplier) || other.parsedMultiplier == parsedMultiplier)&&(identical(other.manualMultiplier, manualMultiplier) || other.manualMultiplier == manualMultiplier)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nodeName,parsedMultiplier,manualMultiplier,updatedAt);

@override
String toString() {
  return 'NodeMultiplier(nodeName: $nodeName, parsedMultiplier: $parsedMultiplier, manualMultiplier: $manualMultiplier, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NodeMultiplierCopyWith<$Res>  {
  factory $NodeMultiplierCopyWith(NodeMultiplier value, $Res Function(NodeMultiplier) _then) = _$NodeMultiplierCopyWithImpl;
@useResult
$Res call({
 String nodeName, double parsedMultiplier, double? manualMultiplier, DateTime updatedAt
});




}
/// @nodoc
class _$NodeMultiplierCopyWithImpl<$Res>
    implements $NodeMultiplierCopyWith<$Res> {
  _$NodeMultiplierCopyWithImpl(this._self, this._then);

  final NodeMultiplier _self;
  final $Res Function(NodeMultiplier) _then;

/// Create a copy of NodeMultiplier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodeName = null,Object? parsedMultiplier = null,Object? manualMultiplier = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
nodeName: null == nodeName ? _self.nodeName : nodeName // ignore: cast_nullable_to_non_nullable
as String,parsedMultiplier: null == parsedMultiplier ? _self.parsedMultiplier : parsedMultiplier // ignore: cast_nullable_to_non_nullable
as double,manualMultiplier: freezed == manualMultiplier ? _self.manualMultiplier : manualMultiplier // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NodeMultiplier].
extension NodeMultiplierPatterns on NodeMultiplier {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NodeMultiplier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NodeMultiplier() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NodeMultiplier value)  $default,){
final _that = this;
switch (_that) {
case _NodeMultiplier():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NodeMultiplier value)?  $default,){
final _that = this;
switch (_that) {
case _NodeMultiplier() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nodeName,  double parsedMultiplier,  double? manualMultiplier,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NodeMultiplier() when $default != null:
return $default(_that.nodeName,_that.parsedMultiplier,_that.manualMultiplier,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nodeName,  double parsedMultiplier,  double? manualMultiplier,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NodeMultiplier():
return $default(_that.nodeName,_that.parsedMultiplier,_that.manualMultiplier,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nodeName,  double parsedMultiplier,  double? manualMultiplier,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NodeMultiplier() when $default != null:
return $default(_that.nodeName,_that.parsedMultiplier,_that.manualMultiplier,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NodeMultiplier implements NodeMultiplier {
  const _NodeMultiplier({required this.nodeName, required this.parsedMultiplier, this.manualMultiplier, required this.updatedAt});
  factory _NodeMultiplier.fromJson(Map<String, dynamic> json) => _$NodeMultiplierFromJson(json);

@override final  String nodeName;
@override final  double parsedMultiplier;
@override final  double? manualMultiplier;
@override final  DateTime updatedAt;

/// Create a copy of NodeMultiplier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NodeMultiplierCopyWith<_NodeMultiplier> get copyWith => __$NodeMultiplierCopyWithImpl<_NodeMultiplier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NodeMultiplierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NodeMultiplier&&(identical(other.nodeName, nodeName) || other.nodeName == nodeName)&&(identical(other.parsedMultiplier, parsedMultiplier) || other.parsedMultiplier == parsedMultiplier)&&(identical(other.manualMultiplier, manualMultiplier) || other.manualMultiplier == manualMultiplier)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nodeName,parsedMultiplier,manualMultiplier,updatedAt);

@override
String toString() {
  return 'NodeMultiplier(nodeName: $nodeName, parsedMultiplier: $parsedMultiplier, manualMultiplier: $manualMultiplier, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NodeMultiplierCopyWith<$Res> implements $NodeMultiplierCopyWith<$Res> {
  factory _$NodeMultiplierCopyWith(_NodeMultiplier value, $Res Function(_NodeMultiplier) _then) = __$NodeMultiplierCopyWithImpl;
@override @useResult
$Res call({
 String nodeName, double parsedMultiplier, double? manualMultiplier, DateTime updatedAt
});




}
/// @nodoc
class __$NodeMultiplierCopyWithImpl<$Res>
    implements _$NodeMultiplierCopyWith<$Res> {
  __$NodeMultiplierCopyWithImpl(this._self, this._then);

  final _NodeMultiplier _self;
  final $Res Function(_NodeMultiplier) _then;

/// Create a copy of NodeMultiplier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodeName = null,Object? parsedMultiplier = null,Object? manualMultiplier = freezed,Object? updatedAt = null,}) {
  return _then(_NodeMultiplier(
nodeName: null == nodeName ? _self.nodeName : nodeName // ignore: cast_nullable_to_non_nullable
as String,parsedMultiplier: null == parsedMultiplier ? _self.parsedMultiplier : parsedMultiplier // ignore: cast_nullable_to_non_nullable
as double,manualMultiplier: freezed == manualMultiplier ? _self.manualMultiplier : manualMultiplier // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$LedgerSettings {

/// 是否启用自动周期切换。默认关闭。
 bool get autoCycleEnabled;/// 每月刷新日，取值范围 1–28。默认 1（等价于自然月初）。
 int get billingCycleDay;/// 刷新小时。第一版固定为 0（00:00），预留字段以便后续支持自定义时刻。
 int get billingCycleHour; DateTime? get updatedAt;
/// Create a copy of LedgerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerSettingsCopyWith<LedgerSettings> get copyWith => _$LedgerSettingsCopyWithImpl<LedgerSettings>(this as LedgerSettings, _$identity);

  /// Serializes this LedgerSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerSettings&&(identical(other.autoCycleEnabled, autoCycleEnabled) || other.autoCycleEnabled == autoCycleEnabled)&&(identical(other.billingCycleDay, billingCycleDay) || other.billingCycleDay == billingCycleDay)&&(identical(other.billingCycleHour, billingCycleHour) || other.billingCycleHour == billingCycleHour)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,autoCycleEnabled,billingCycleDay,billingCycleHour,updatedAt);

@override
String toString() {
  return 'LedgerSettings(autoCycleEnabled: $autoCycleEnabled, billingCycleDay: $billingCycleDay, billingCycleHour: $billingCycleHour, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LedgerSettingsCopyWith<$Res>  {
  factory $LedgerSettingsCopyWith(LedgerSettings value, $Res Function(LedgerSettings) _then) = _$LedgerSettingsCopyWithImpl;
@useResult
$Res call({
 bool autoCycleEnabled, int billingCycleDay, int billingCycleHour, DateTime? updatedAt
});




}
/// @nodoc
class _$LedgerSettingsCopyWithImpl<$Res>
    implements $LedgerSettingsCopyWith<$Res> {
  _$LedgerSettingsCopyWithImpl(this._self, this._then);

  final LedgerSettings _self;
  final $Res Function(LedgerSettings) _then;

/// Create a copy of LedgerSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoCycleEnabled = null,Object? billingCycleDay = null,Object? billingCycleHour = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
autoCycleEnabled: null == autoCycleEnabled ? _self.autoCycleEnabled : autoCycleEnabled // ignore: cast_nullable_to_non_nullable
as bool,billingCycleDay: null == billingCycleDay ? _self.billingCycleDay : billingCycleDay // ignore: cast_nullable_to_non_nullable
as int,billingCycleHour: null == billingCycleHour ? _self.billingCycleHour : billingCycleHour // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerSettings].
extension LedgerSettingsPatterns on LedgerSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerSettings value)  $default,){
final _that = this;
switch (_that) {
case _LedgerSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerSettings value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool autoCycleEnabled,  int billingCycleDay,  int billingCycleHour,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerSettings() when $default != null:
return $default(_that.autoCycleEnabled,_that.billingCycleDay,_that.billingCycleHour,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool autoCycleEnabled,  int billingCycleDay,  int billingCycleHour,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _LedgerSettings():
return $default(_that.autoCycleEnabled,_that.billingCycleDay,_that.billingCycleHour,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool autoCycleEnabled,  int billingCycleDay,  int billingCycleHour,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _LedgerSettings() when $default != null:
return $default(_that.autoCycleEnabled,_that.billingCycleDay,_that.billingCycleHour,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerSettings implements LedgerSettings {
  const _LedgerSettings({this.autoCycleEnabled = false, this.billingCycleDay = 1, this.billingCycleHour = 0, this.updatedAt});
  factory _LedgerSettings.fromJson(Map<String, dynamic> json) => _$LedgerSettingsFromJson(json);

/// 是否启用自动周期切换。默认关闭。
@override@JsonKey() final  bool autoCycleEnabled;
/// 每月刷新日，取值范围 1–28。默认 1（等价于自然月初）。
@override@JsonKey() final  int billingCycleDay;
/// 刷新小时。第一版固定为 0（00:00），预留字段以便后续支持自定义时刻。
@override@JsonKey() final  int billingCycleHour;
@override final  DateTime? updatedAt;

/// Create a copy of LedgerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerSettingsCopyWith<_LedgerSettings> get copyWith => __$LedgerSettingsCopyWithImpl<_LedgerSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerSettings&&(identical(other.autoCycleEnabled, autoCycleEnabled) || other.autoCycleEnabled == autoCycleEnabled)&&(identical(other.billingCycleDay, billingCycleDay) || other.billingCycleDay == billingCycleDay)&&(identical(other.billingCycleHour, billingCycleHour) || other.billingCycleHour == billingCycleHour)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,autoCycleEnabled,billingCycleDay,billingCycleHour,updatedAt);

@override
String toString() {
  return 'LedgerSettings(autoCycleEnabled: $autoCycleEnabled, billingCycleDay: $billingCycleDay, billingCycleHour: $billingCycleHour, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LedgerSettingsCopyWith<$Res> implements $LedgerSettingsCopyWith<$Res> {
  factory _$LedgerSettingsCopyWith(_LedgerSettings value, $Res Function(_LedgerSettings) _then) = __$LedgerSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool autoCycleEnabled, int billingCycleDay, int billingCycleHour, DateTime? updatedAt
});




}
/// @nodoc
class __$LedgerSettingsCopyWithImpl<$Res>
    implements _$LedgerSettingsCopyWith<$Res> {
  __$LedgerSettingsCopyWithImpl(this._self, this._then);

  final _LedgerSettings _self;
  final $Res Function(_LedgerSettings) _then;

/// Create a copy of LedgerSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoCycleEnabled = null,Object? billingCycleDay = null,Object? billingCycleHour = null,Object? updatedAt = freezed,}) {
  return _then(_LedgerSettings(
autoCycleEnabled: null == autoCycleEnabled ? _self.autoCycleEnabled : autoCycleEnabled // ignore: cast_nullable_to_non_nullable
as bool,billingCycleDay: null == billingCycleDay ? _self.billingCycleDay : billingCycleDay // ignore: cast_nullable_to_non_nullable
as int,billingCycleHour: null == billingCycleHour ? _self.billingCycleHour : billingCycleHour // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
