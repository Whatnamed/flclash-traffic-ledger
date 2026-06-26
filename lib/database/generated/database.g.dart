// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, RawProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentGroupNameMeta = const VerificationMeta(
    'currentGroupName',
  );
  @override
  late final GeneratedColumn<String> currentGroupName = GeneratedColumn<String>(
    'current_group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateDateMeta = const VerificationMeta(
    'lastUpdateDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateDate =
      GeneratedColumn<DateTime>(
        'last_update_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<OverwriteType, String>
  overwriteType = GeneratedColumn<String>(
    'overwrite_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<OverwriteType>($ProfilesTable.$converteroverwriteType);
  static const VerificationMeta _scriptIdMeta = const VerificationMeta(
    'scriptId',
  );
  @override
  late final GeneratedColumn<int> scriptId = GeneratedColumn<int>(
    'script_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoUpdateDurationMillisMeta =
      const VerificationMeta('autoUpdateDurationMillis');
  @override
  late final GeneratedColumn<int> autoUpdateDurationMillis =
      GeneratedColumn<int>(
        'auto_update_duration_millis',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  subscriptionInfo = GeneratedColumn<String>(
    'subscription_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<SubscriptionInfo?>($ProfilesTable.$convertersubscriptionInfo);
  static const VerificationMeta _autoUpdateMeta = const VerificationMeta(
    'autoUpdate',
  );
  @override
  late final GeneratedColumn<bool> autoUpdate = GeneratedColumn<bool>(
    'auto_update',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_update" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  selectedMap = GeneratedColumn<String>(
    'selected_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($ProfilesTable.$converterselectedMap);
  @override
  late final GeneratedColumnWithTypeConverter<Set<String>, String> unfoldSet =
      GeneratedColumn<String>(
        'unfold_set',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<String>>($ProfilesTable.$converterunfoldSet);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    currentGroupName,
    url,
    lastUpdateDate,
    overwriteType,
    scriptId,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('current_group_name')) {
      context.handle(
        _currentGroupNameMeta,
        currentGroupName.isAcceptableOrUnknown(
          data['current_group_name']!,
          _currentGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_update_date')) {
      context.handle(
        _lastUpdateDateMeta,
        lastUpdateDate.isAcceptableOrUnknown(
          data['last_update_date']!,
          _lastUpdateDateMeta,
        ),
      );
    }
    if (data.containsKey('script_id')) {
      context.handle(
        _scriptIdMeta,
        scriptId.isAcceptableOrUnknown(data['script_id']!, _scriptIdMeta),
      );
    }
    if (data.containsKey('auto_update_duration_millis')) {
      context.handle(
        _autoUpdateDurationMillisMeta,
        autoUpdateDurationMillis.isAcceptableOrUnknown(
          data['auto_update_duration_millis']!,
          _autoUpdateDurationMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateDurationMillisMeta);
    }
    if (data.containsKey('auto_update')) {
      context.handle(
        _autoUpdateMeta,
        autoUpdate.isAcceptableOrUnknown(data['auto_update']!, _autoUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      currentGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_group_name'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastUpdateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_date'],
      ),
      overwriteType: $ProfilesTable.$converteroverwriteType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}overwrite_type'],
        )!,
      ),
      scriptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}script_id'],
      ),
      autoUpdateDurationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_duration_millis'],
      )!,
      subscriptionInfo: $ProfilesTable.$convertersubscriptionInfo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subscription_info'],
        ),
      ),
      autoUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_update'],
      )!,
      selectedMap: $ProfilesTable.$converterselectedMap.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_map'],
        )!,
      ),
      unfoldSet: $ProfilesTable.$converterunfoldSet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unfold_set'],
        )!,
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OverwriteType, String, String>
  $converteroverwriteType = const EnumNameConverter<OverwriteType>(
    OverwriteType.values,
  );
  static TypeConverter<SubscriptionInfo?, String?> $convertersubscriptionInfo =
      const SubscriptionInfoConverter();
  static TypeConverter<Map<String, String>, String> $converterselectedMap =
      const StringMapConverter();
  static TypeConverter<Set<String>, String> $converterunfoldSet =
      const StringSetConverter();
}

class RawProfile extends DataClass implements Insertable<RawProfile> {
  final int id;
  final String label;
  final String? currentGroupName;
  final String url;
  final DateTime? lastUpdateDate;
  final OverwriteType overwriteType;
  final int? scriptId;
  final int autoUpdateDurationMillis;
  final SubscriptionInfo? subscriptionInfo;
  final bool autoUpdate;
  final Map<String, String> selectedMap;
  final Set<String> unfoldSet;
  final int? order;
  const RawProfile({
    required this.id,
    required this.label,
    this.currentGroupName,
    required this.url,
    this.lastUpdateDate,
    required this.overwriteType,
    this.scriptId,
    required this.autoUpdateDurationMillis,
    this.subscriptionInfo,
    required this.autoUpdate,
    required this.selectedMap,
    required this.unfoldSet,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || currentGroupName != null) {
      map['current_group_name'] = Variable<String>(currentGroupName);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || lastUpdateDate != null) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate);
    }
    {
      map['overwrite_type'] = Variable<String>(
        $ProfilesTable.$converteroverwriteType.toSql(overwriteType),
      );
    }
    if (!nullToAbsent || scriptId != null) {
      map['script_id'] = Variable<int>(scriptId);
    }
    map['auto_update_duration_millis'] = Variable<int>(
      autoUpdateDurationMillis,
    );
    if (!nullToAbsent || subscriptionInfo != null) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo),
      );
    }
    map['auto_update'] = Variable<bool>(autoUpdate);
    {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap),
      );
    }
    {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      label: Value(label),
      currentGroupName: currentGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(currentGroupName),
      url: Value(url),
      lastUpdateDate: lastUpdateDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateDate),
      overwriteType: Value(overwriteType),
      scriptId: scriptId == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptId),
      autoUpdateDurationMillis: Value(autoUpdateDurationMillis),
      subscriptionInfo: subscriptionInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionInfo),
      autoUpdate: Value(autoUpdate),
      selectedMap: Value(selectedMap),
      unfoldSet: Value(unfoldSet),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProfile(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      currentGroupName: serializer.fromJson<String?>(json['currentGroupName']),
      url: serializer.fromJson<String>(json['url']),
      lastUpdateDate: serializer.fromJson<DateTime?>(json['lastUpdateDate']),
      overwriteType: $ProfilesTable.$converteroverwriteType.fromJson(
        serializer.fromJson<String>(json['overwriteType']),
      ),
      scriptId: serializer.fromJson<int?>(json['scriptId']),
      autoUpdateDurationMillis: serializer.fromJson<int>(
        json['autoUpdateDurationMillis'],
      ),
      subscriptionInfo: serializer.fromJson<SubscriptionInfo?>(
        json['subscriptionInfo'],
      ),
      autoUpdate: serializer.fromJson<bool>(json['autoUpdate']),
      selectedMap: serializer.fromJson<Map<String, String>>(
        json['selectedMap'],
      ),
      unfoldSet: serializer.fromJson<Set<String>>(json['unfoldSet']),
      order: serializer.fromJson<int?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'currentGroupName': serializer.toJson<String?>(currentGroupName),
      'url': serializer.toJson<String>(url),
      'lastUpdateDate': serializer.toJson<DateTime?>(lastUpdateDate),
      'overwriteType': serializer.toJson<String>(
        $ProfilesTable.$converteroverwriteType.toJson(overwriteType),
      ),
      'scriptId': serializer.toJson<int?>(scriptId),
      'autoUpdateDurationMillis': serializer.toJson<int>(
        autoUpdateDurationMillis,
      ),
      'subscriptionInfo': serializer.toJson<SubscriptionInfo?>(
        subscriptionInfo,
      ),
      'autoUpdate': serializer.toJson<bool>(autoUpdate),
      'selectedMap': serializer.toJson<Map<String, String>>(selectedMap),
      'unfoldSet': serializer.toJson<Set<String>>(unfoldSet),
      'order': serializer.toJson<int?>(order),
    };
  }

  RawProfile copyWith({
    int? id,
    String? label,
    Value<String?> currentGroupName = const Value.absent(),
    String? url,
    Value<DateTime?> lastUpdateDate = const Value.absent(),
    OverwriteType? overwriteType,
    Value<int?> scriptId = const Value.absent(),
    int? autoUpdateDurationMillis,
    Value<SubscriptionInfo?> subscriptionInfo = const Value.absent(),
    bool? autoUpdate,
    Map<String, String>? selectedMap,
    Set<String>? unfoldSet,
    Value<int?> order = const Value.absent(),
  }) => RawProfile(
    id: id ?? this.id,
    label: label ?? this.label,
    currentGroupName: currentGroupName.present
        ? currentGroupName.value
        : this.currentGroupName,
    url: url ?? this.url,
    lastUpdateDate: lastUpdateDate.present
        ? lastUpdateDate.value
        : this.lastUpdateDate,
    overwriteType: overwriteType ?? this.overwriteType,
    scriptId: scriptId.present ? scriptId.value : this.scriptId,
    autoUpdateDurationMillis:
        autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
    subscriptionInfo: subscriptionInfo.present
        ? subscriptionInfo.value
        : this.subscriptionInfo,
    autoUpdate: autoUpdate ?? this.autoUpdate,
    selectedMap: selectedMap ?? this.selectedMap,
    unfoldSet: unfoldSet ?? this.unfoldSet,
    order: order.present ? order.value : this.order,
  );
  RawProfile copyWithCompanion(ProfilesCompanion data) {
    return RawProfile(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      currentGroupName: data.currentGroupName.present
          ? data.currentGroupName.value
          : this.currentGroupName,
      url: data.url.present ? data.url.value : this.url,
      lastUpdateDate: data.lastUpdateDate.present
          ? data.lastUpdateDate.value
          : this.lastUpdateDate,
      overwriteType: data.overwriteType.present
          ? data.overwriteType.value
          : this.overwriteType,
      scriptId: data.scriptId.present ? data.scriptId.value : this.scriptId,
      autoUpdateDurationMillis: data.autoUpdateDurationMillis.present
          ? data.autoUpdateDurationMillis.value
          : this.autoUpdateDurationMillis,
      subscriptionInfo: data.subscriptionInfo.present
          ? data.subscriptionInfo.value
          : this.subscriptionInfo,
      autoUpdate: data.autoUpdate.present
          ? data.autoUpdate.value
          : this.autoUpdate,
      selectedMap: data.selectedMap.present
          ? data.selectedMap.value
          : this.selectedMap,
      unfoldSet: data.unfoldSet.present ? data.unfoldSet.value : this.unfoldSet,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProfile(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('overwriteType: $overwriteType, ')
          ..write('scriptId: $scriptId, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    currentGroupName,
    url,
    lastUpdateDate,
    overwriteType,
    scriptId,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProfile &&
          other.id == this.id &&
          other.label == this.label &&
          other.currentGroupName == this.currentGroupName &&
          other.url == this.url &&
          other.lastUpdateDate == this.lastUpdateDate &&
          other.overwriteType == this.overwriteType &&
          other.scriptId == this.scriptId &&
          other.autoUpdateDurationMillis == this.autoUpdateDurationMillis &&
          other.subscriptionInfo == this.subscriptionInfo &&
          other.autoUpdate == this.autoUpdate &&
          other.selectedMap == this.selectedMap &&
          other.unfoldSet == this.unfoldSet &&
          other.order == this.order);
}

class ProfilesCompanion extends UpdateCompanion<RawProfile> {
  final Value<int> id;
  final Value<String> label;
  final Value<String?> currentGroupName;
  final Value<String> url;
  final Value<DateTime?> lastUpdateDate;
  final Value<OverwriteType> overwriteType;
  final Value<int?> scriptId;
  final Value<int> autoUpdateDurationMillis;
  final Value<SubscriptionInfo?> subscriptionInfo;
  final Value<bool> autoUpdate;
  final Value<Map<String, String>> selectedMap;
  final Value<Set<String>> unfoldSet;
  final Value<int?> order;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.currentGroupName = const Value.absent(),
    this.url = const Value.absent(),
    this.lastUpdateDate = const Value.absent(),
    this.overwriteType = const Value.absent(),
    this.scriptId = const Value.absent(),
    this.autoUpdateDurationMillis = const Value.absent(),
    this.subscriptionInfo = const Value.absent(),
    this.autoUpdate = const Value.absent(),
    this.selectedMap = const Value.absent(),
    this.unfoldSet = const Value.absent(),
    this.order = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    this.currentGroupName = const Value.absent(),
    required String url,
    this.lastUpdateDate = const Value.absent(),
    required OverwriteType overwriteType,
    this.scriptId = const Value.absent(),
    required int autoUpdateDurationMillis,
    this.subscriptionInfo = const Value.absent(),
    required bool autoUpdate,
    required Map<String, String> selectedMap,
    required Set<String> unfoldSet,
    this.order = const Value.absent(),
  }) : label = Value(label),
       url = Value(url),
       overwriteType = Value(overwriteType),
       autoUpdateDurationMillis = Value(autoUpdateDurationMillis),
       autoUpdate = Value(autoUpdate),
       selectedMap = Value(selectedMap),
       unfoldSet = Value(unfoldSet);
  static Insertable<RawProfile> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? currentGroupName,
    Expression<String>? url,
    Expression<DateTime>? lastUpdateDate,
    Expression<String>? overwriteType,
    Expression<int>? scriptId,
    Expression<int>? autoUpdateDurationMillis,
    Expression<String>? subscriptionInfo,
    Expression<bool>? autoUpdate,
    Expression<String>? selectedMap,
    Expression<String>? unfoldSet,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (currentGroupName != null) 'current_group_name': currentGroupName,
      if (url != null) 'url': url,
      if (lastUpdateDate != null) 'last_update_date': lastUpdateDate,
      if (overwriteType != null) 'overwrite_type': overwriteType,
      if (scriptId != null) 'script_id': scriptId,
      if (autoUpdateDurationMillis != null)
        'auto_update_duration_millis': autoUpdateDurationMillis,
      if (subscriptionInfo != null) 'subscription_info': subscriptionInfo,
      if (autoUpdate != null) 'auto_update': autoUpdate,
      if (selectedMap != null) 'selected_map': selectedMap,
      if (unfoldSet != null) 'unfold_set': unfoldSet,
      if (order != null) 'order': order,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String?>? currentGroupName,
    Value<String>? url,
    Value<DateTime?>? lastUpdateDate,
    Value<OverwriteType>? overwriteType,
    Value<int?>? scriptId,
    Value<int>? autoUpdateDurationMillis,
    Value<SubscriptionInfo?>? subscriptionInfo,
    Value<bool>? autoUpdate,
    Value<Map<String, String>>? selectedMap,
    Value<Set<String>>? unfoldSet,
    Value<int?>? order,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      url: url ?? this.url,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      overwriteType: overwriteType ?? this.overwriteType,
      scriptId: scriptId ?? this.scriptId,
      autoUpdateDurationMillis:
          autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      selectedMap: selectedMap ?? this.selectedMap,
      unfoldSet: unfoldSet ?? this.unfoldSet,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (currentGroupName.present) {
      map['current_group_name'] = Variable<String>(currentGroupName.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastUpdateDate.present) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate.value);
    }
    if (overwriteType.present) {
      map['overwrite_type'] = Variable<String>(
        $ProfilesTable.$converteroverwriteType.toSql(overwriteType.value),
      );
    }
    if (scriptId.present) {
      map['script_id'] = Variable<int>(scriptId.value);
    }
    if (autoUpdateDurationMillis.present) {
      map['auto_update_duration_millis'] = Variable<int>(
        autoUpdateDurationMillis.value,
      );
    }
    if (subscriptionInfo.present) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo.value),
      );
    }
    if (autoUpdate.present) {
      map['auto_update'] = Variable<bool>(autoUpdate.value);
    }
    if (selectedMap.present) {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap.value),
      );
    }
    if (unfoldSet.present) {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('overwriteType: $overwriteType, ')
          ..write('scriptId: $scriptId, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $ScriptsTable extends Scripts with TableInfo<$ScriptsTable, RawScript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateTimeMeta = const VerificationMeta(
    'lastUpdateTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateTime =
      GeneratedColumn<DateTime>(
        'last_update_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [id, label, lastUpdateTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawScript> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('last_update_time')) {
      context.handle(
        _lastUpdateTimeMeta,
        lastUpdateTime.isAcceptableOrUnknown(
          data['last_update_time']!,
          _lastUpdateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdateTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawScript map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawScript(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      lastUpdateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_time'],
      )!,
    );
  }

  @override
  $ScriptsTable createAlias(String alias) {
    return $ScriptsTable(attachedDatabase, alias);
  }
}

class RawScript extends DataClass implements Insertable<RawScript> {
  final int id;
  final String label;
  final DateTime lastUpdateTime;
  const RawScript({
    required this.id,
    required this.label,
    required this.lastUpdateTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['last_update_time'] = Variable<DateTime>(lastUpdateTime);
    return map;
  }

  ScriptsCompanion toCompanion(bool nullToAbsent) {
    return ScriptsCompanion(
      id: Value(id),
      label: Value(label),
      lastUpdateTime: Value(lastUpdateTime),
    );
  }

  factory RawScript.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawScript(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      lastUpdateTime: serializer.fromJson<DateTime>(json['lastUpdateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'lastUpdateTime': serializer.toJson<DateTime>(lastUpdateTime),
    };
  }

  RawScript copyWith({int? id, String? label, DateTime? lastUpdateTime}) =>
      RawScript(
        id: id ?? this.id,
        label: label ?? this.label,
        lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      );
  RawScript copyWithCompanion(ScriptsCompanion data) {
    return RawScript(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      lastUpdateTime: data.lastUpdateTime.present
          ? data.lastUpdateTime.value
          : this.lastUpdateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawScript(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('lastUpdateTime: $lastUpdateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, lastUpdateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawScript &&
          other.id == this.id &&
          other.label == this.label &&
          other.lastUpdateTime == this.lastUpdateTime);
}

class ScriptsCompanion extends UpdateCompanion<RawScript> {
  final Value<int> id;
  final Value<String> label;
  final Value<DateTime> lastUpdateTime;
  const ScriptsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
  });
  ScriptsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required DateTime lastUpdateTime,
  }) : label = Value(label),
       lastUpdateTime = Value(lastUpdateTime);
  static Insertable<RawScript> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<DateTime>? lastUpdateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (lastUpdateTime != null) 'last_update_time': lastUpdateTime,
    });
  }

  ScriptsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<DateTime>? lastUpdateTime,
  }) {
    return ScriptsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (lastUpdateTime.present) {
      map['last_update_time'] = Variable<DateTime>(lastUpdateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScriptsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('lastUpdateTime: $lastUpdateTime')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, RawRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleAction, String> ruleAction =
      GeneratedColumn<String>(
        'rule_action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RuleAction>($RulesTable.$converterruleAction);
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleTargetMeta = const VerificationMeta(
    'ruleTarget',
  );
  @override
  late final GeneratedColumn<String> ruleTarget = GeneratedColumn<String>(
    'rule_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleProviderMeta = const VerificationMeta(
    'ruleProvider',
  );
  @override
  late final GeneratedColumn<String> ruleProvider = GeneratedColumn<String>(
    'rule_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subRuleMeta = const VerificationMeta(
    'subRule',
  );
  @override
  late final GeneratedColumn<String> subRule = GeneratedColumn<String>(
    'sub_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noResolveMeta = const VerificationMeta(
    'noResolve',
  );
  @override
  late final GeneratedColumn<bool> noResolve = GeneratedColumn<bool>(
    'no_resolve',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_resolve" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _srcMeta = const VerificationMeta('src');
  @override
  late final GeneratedColumn<bool> src = GeneratedColumn<bool>(
    'src',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("src" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleAction,
    content,
    ruleTarget,
    ruleProvider,
    subRule,
    noResolve,
    src,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('rule_target')) {
      context.handle(
        _ruleTargetMeta,
        ruleTarget.isAcceptableOrUnknown(data['rule_target']!, _ruleTargetMeta),
      );
    }
    if (data.containsKey('rule_provider')) {
      context.handle(
        _ruleProviderMeta,
        ruleProvider.isAcceptableOrUnknown(
          data['rule_provider']!,
          _ruleProviderMeta,
        ),
      );
    }
    if (data.containsKey('sub_rule')) {
      context.handle(
        _subRuleMeta,
        subRule.isAcceptableOrUnknown(data['sub_rule']!, _subRuleMeta),
      );
    }
    if (data.containsKey('no_resolve')) {
      context.handle(
        _noResolveMeta,
        noResolve.isAcceptableOrUnknown(data['no_resolve']!, _noResolveMeta),
      );
    }
    if (data.containsKey('src')) {
      context.handle(
        _srcMeta,
        src.isAcceptableOrUnknown(data['src']!, _srcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ruleAction: $RulesTable.$converterruleAction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rule_action'],
        )!,
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      ruleTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_target'],
      ),
      ruleProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_provider'],
      ),
      subRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_rule'],
      ),
      noResolve: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}no_resolve'],
      )!,
      src: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}src'],
      )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RuleAction, String, String> $converterruleAction =
      const EnumNameConverter<RuleAction>(RuleAction.values);
}

class RawRule extends DataClass implements Insertable<RawRule> {
  final int id;
  final RuleAction ruleAction;
  final String? content;
  final String? ruleTarget;
  final String? ruleProvider;
  final String? subRule;
  final bool noResolve;
  final bool src;
  const RawRule({
    required this.id,
    required this.ruleAction,
    this.content,
    this.ruleTarget,
    this.ruleProvider,
    this.subRule,
    required this.noResolve,
    required this.src,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['rule_action'] = Variable<String>(
        $RulesTable.$converterruleAction.toSql(ruleAction),
      );
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || ruleTarget != null) {
      map['rule_target'] = Variable<String>(ruleTarget);
    }
    if (!nullToAbsent || ruleProvider != null) {
      map['rule_provider'] = Variable<String>(ruleProvider);
    }
    if (!nullToAbsent || subRule != null) {
      map['sub_rule'] = Variable<String>(subRule);
    }
    map['no_resolve'] = Variable<bool>(noResolve);
    map['src'] = Variable<bool>(src);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      ruleAction: Value(ruleAction),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      ruleTarget: ruleTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleTarget),
      ruleProvider: ruleProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleProvider),
      subRule: subRule == null && nullToAbsent
          ? const Value.absent()
          : Value(subRule),
      noResolve: Value(noResolve),
      src: Value(src),
    );
  }

  factory RawRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawRule(
      id: serializer.fromJson<int>(json['id']),
      ruleAction: $RulesTable.$converterruleAction.fromJson(
        serializer.fromJson<String>(json['ruleAction']),
      ),
      content: serializer.fromJson<String?>(json['content']),
      ruleTarget: serializer.fromJson<String?>(json['ruleTarget']),
      ruleProvider: serializer.fromJson<String?>(json['ruleProvider']),
      subRule: serializer.fromJson<String?>(json['subRule']),
      noResolve: serializer.fromJson<bool>(json['noResolve']),
      src: serializer.fromJson<bool>(json['src']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruleAction': serializer.toJson<String>(
        $RulesTable.$converterruleAction.toJson(ruleAction),
      ),
      'content': serializer.toJson<String?>(content),
      'ruleTarget': serializer.toJson<String?>(ruleTarget),
      'ruleProvider': serializer.toJson<String?>(ruleProvider),
      'subRule': serializer.toJson<String?>(subRule),
      'noResolve': serializer.toJson<bool>(noResolve),
      'src': serializer.toJson<bool>(src),
    };
  }

  RawRule copyWith({
    int? id,
    RuleAction? ruleAction,
    Value<String?> content = const Value.absent(),
    Value<String?> ruleTarget = const Value.absent(),
    Value<String?> ruleProvider = const Value.absent(),
    Value<String?> subRule = const Value.absent(),
    bool? noResolve,
    bool? src,
  }) => RawRule(
    id: id ?? this.id,
    ruleAction: ruleAction ?? this.ruleAction,
    content: content.present ? content.value : this.content,
    ruleTarget: ruleTarget.present ? ruleTarget.value : this.ruleTarget,
    ruleProvider: ruleProvider.present ? ruleProvider.value : this.ruleProvider,
    subRule: subRule.present ? subRule.value : this.subRule,
    noResolve: noResolve ?? this.noResolve,
    src: src ?? this.src,
  );
  RawRule copyWithCompanion(RulesCompanion data) {
    return RawRule(
      id: data.id.present ? data.id.value : this.id,
      ruleAction: data.ruleAction.present
          ? data.ruleAction.value
          : this.ruleAction,
      content: data.content.present ? data.content.value : this.content,
      ruleTarget: data.ruleTarget.present
          ? data.ruleTarget.value
          : this.ruleTarget,
      ruleProvider: data.ruleProvider.present
          ? data.ruleProvider.value
          : this.ruleProvider,
      subRule: data.subRule.present ? data.subRule.value : this.subRule,
      noResolve: data.noResolve.present ? data.noResolve.value : this.noResolve,
      src: data.src.present ? data.src.value : this.src,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawRule(')
          ..write('id: $id, ')
          ..write('ruleAction: $ruleAction, ')
          ..write('content: $content, ')
          ..write('ruleTarget: $ruleTarget, ')
          ..write('ruleProvider: $ruleProvider, ')
          ..write('subRule: $subRule, ')
          ..write('noResolve: $noResolve, ')
          ..write('src: $src')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleAction,
    content,
    ruleTarget,
    ruleProvider,
    subRule,
    noResolve,
    src,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawRule &&
          other.id == this.id &&
          other.ruleAction == this.ruleAction &&
          other.content == this.content &&
          other.ruleTarget == this.ruleTarget &&
          other.ruleProvider == this.ruleProvider &&
          other.subRule == this.subRule &&
          other.noResolve == this.noResolve &&
          other.src == this.src);
}

class RulesCompanion extends UpdateCompanion<RawRule> {
  final Value<int> id;
  final Value<RuleAction> ruleAction;
  final Value<String?> content;
  final Value<String?> ruleTarget;
  final Value<String?> ruleProvider;
  final Value<String?> subRule;
  final Value<bool> noResolve;
  final Value<bool> src;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.ruleAction = const Value.absent(),
    this.content = const Value.absent(),
    this.ruleTarget = const Value.absent(),
    this.ruleProvider = const Value.absent(),
    this.subRule = const Value.absent(),
    this.noResolve = const Value.absent(),
    this.src = const Value.absent(),
  });
  RulesCompanion.insert({
    this.id = const Value.absent(),
    required RuleAction ruleAction,
    this.content = const Value.absent(),
    this.ruleTarget = const Value.absent(),
    this.ruleProvider = const Value.absent(),
    this.subRule = const Value.absent(),
    this.noResolve = const Value.absent(),
    this.src = const Value.absent(),
  }) : ruleAction = Value(ruleAction);
  static Insertable<RawRule> custom({
    Expression<int>? id,
    Expression<String>? ruleAction,
    Expression<String>? content,
    Expression<String>? ruleTarget,
    Expression<String>? ruleProvider,
    Expression<String>? subRule,
    Expression<bool>? noResolve,
    Expression<bool>? src,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleAction != null) 'rule_action': ruleAction,
      if (content != null) 'content': content,
      if (ruleTarget != null) 'rule_target': ruleTarget,
      if (ruleProvider != null) 'rule_provider': ruleProvider,
      if (subRule != null) 'sub_rule': subRule,
      if (noResolve != null) 'no_resolve': noResolve,
      if (src != null) 'src': src,
    });
  }

  RulesCompanion copyWith({
    Value<int>? id,
    Value<RuleAction>? ruleAction,
    Value<String?>? content,
    Value<String?>? ruleTarget,
    Value<String?>? ruleProvider,
    Value<String?>? subRule,
    Value<bool>? noResolve,
    Value<bool>? src,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      ruleAction: ruleAction ?? this.ruleAction,
      content: content ?? this.content,
      ruleTarget: ruleTarget ?? this.ruleTarget,
      ruleProvider: ruleProvider ?? this.ruleProvider,
      subRule: subRule ?? this.subRule,
      noResolve: noResolve ?? this.noResolve,
      src: src ?? this.src,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ruleAction.present) {
      map['rule_action'] = Variable<String>(
        $RulesTable.$converterruleAction.toSql(ruleAction.value),
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (ruleTarget.present) {
      map['rule_target'] = Variable<String>(ruleTarget.value);
    }
    if (ruleProvider.present) {
      map['rule_provider'] = Variable<String>(ruleProvider.value);
    }
    if (subRule.present) {
      map['sub_rule'] = Variable<String>(subRule.value);
    }
    if (noResolve.present) {
      map['no_resolve'] = Variable<bool>(noResolve.value);
    }
    if (src.present) {
      map['src'] = Variable<bool>(src.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('ruleAction: $ruleAction, ')
          ..write('content: $content, ')
          ..write('ruleTarget: $ruleTarget, ')
          ..write('ruleProvider: $ruleProvider, ')
          ..write('subRule: $subRule, ')
          ..write('noResolve: $noResolve, ')
          ..write('src: $src')
          ..write(')'))
        .toString();
  }
}

class $ProfileRuleLinksTable extends ProfileRuleLinks
    with TableInfo<$ProfileRuleLinksTable, RawProfileRuleLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRuleLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rules (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleScene?, String> scene =
      GeneratedColumn<String>(
        'scene',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RuleScene?>($ProfileRuleLinksTable.$converterscenen);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<String> order = GeneratedColumn<String>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, ruleId, scene, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_rule_mapping';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProfileRuleLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProfileRuleLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProfileRuleLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      scene: $ProfileRuleLinksTable.$converterscenen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}scene'],
        ),
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ProfileRuleLinksTable createAlias(String alias) {
    return $ProfileRuleLinksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RuleScene, String, String> $converterscene =
      const EnumNameConverter<RuleScene>(RuleScene.values);
  static JsonTypeConverter2<RuleScene?, String?, String?> $converterscenen =
      JsonTypeConverter2.asNullable($converterscene);
}

class RawProfileRuleLink extends DataClass
    implements Insertable<RawProfileRuleLink> {
  final String id;
  final int? profileId;
  final int ruleId;
  final RuleScene? scene;
  final String? order;
  const RawProfileRuleLink({
    required this.id,
    this.profileId,
    required this.ruleId,
    this.scene,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['rule_id'] = Variable<int>(ruleId);
    if (!nullToAbsent || scene != null) {
      map['scene'] = Variable<String>(
        $ProfileRuleLinksTable.$converterscenen.toSql(scene),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<String>(order);
    }
    return map;
  }

  ProfileRuleLinksCompanion toCompanion(bool nullToAbsent) {
    return ProfileRuleLinksCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      ruleId: Value(ruleId),
      scene: scene == null && nullToAbsent
          ? const Value.absent()
          : Value(scene),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawProfileRuleLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProfileRuleLink(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      scene: $ProfileRuleLinksTable.$converterscenen.fromJson(
        serializer.fromJson<String?>(json['scene']),
      ),
      order: serializer.fromJson<String?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'ruleId': serializer.toJson<int>(ruleId),
      'scene': serializer.toJson<String?>(
        $ProfileRuleLinksTable.$converterscenen.toJson(scene),
      ),
      'order': serializer.toJson<String?>(order),
    };
  }

  RawProfileRuleLink copyWith({
    String? id,
    Value<int?> profileId = const Value.absent(),
    int? ruleId,
    Value<RuleScene?> scene = const Value.absent(),
    Value<String?> order = const Value.absent(),
  }) => RawProfileRuleLink(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    ruleId: ruleId ?? this.ruleId,
    scene: scene.present ? scene.value : this.scene,
    order: order.present ? order.value : this.order,
  );
  RawProfileRuleLink copyWithCompanion(ProfileRuleLinksCompanion data) {
    return RawProfileRuleLink(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      scene: data.scene.present ? data.scene.value : this.scene,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProfileRuleLink(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('ruleId: $ruleId, ')
          ..write('scene: $scene, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, ruleId, scene, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProfileRuleLink &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.ruleId == this.ruleId &&
          other.scene == this.scene &&
          other.order == this.order);
}

class ProfileRuleLinksCompanion extends UpdateCompanion<RawProfileRuleLink> {
  final Value<String> id;
  final Value<int?> profileId;
  final Value<int> ruleId;
  final Value<RuleScene?> scene;
  final Value<String?> order;
  final Value<int> rowid;
  const ProfileRuleLinksCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.scene = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileRuleLinksCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required int ruleId,
    this.scene = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId);
  static Insertable<RawProfileRuleLink> custom({
    Expression<String>? id,
    Expression<int>? profileId,
    Expression<int>? ruleId,
    Expression<String>? scene,
    Expression<String>? order,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (ruleId != null) 'rule_id': ruleId,
      if (scene != null) 'scene': scene,
      if (order != null) 'order': order,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileRuleLinksCompanion copyWith({
    Value<String>? id,
    Value<int?>? profileId,
    Value<int>? ruleId,
    Value<RuleScene?>? scene,
    Value<String?>? order,
    Value<int>? rowid,
  }) {
    return ProfileRuleLinksCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      ruleId: ruleId ?? this.ruleId,
      scene: scene ?? this.scene,
      order: order ?? this.order,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (scene.present) {
      map['scene'] = Variable<String>(
        $ProfileRuleLinksTable.$converterscenen.toSql(scene.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<String>(order.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRuleLinksCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('ruleId: $ruleId, ')
          ..write('scene: $scene, ')
          ..write('order: $order, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProxyGroupsTable extends ProxyGroups
    with TableInfo<$ProxyGroupsTable, RawProxyGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProxyGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> proxies =
      GeneratedColumn<String>(
        'proxies',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ProxyGroupsTable.$converterproxiesn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> use =
      GeneratedColumn<String>(
        'use',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ProxyGroupsTable.$converterusen);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeoutMeta = const VerificationMeta(
    'timeout',
  );
  @override
  late final GeneratedColumn<int> timeout = GeneratedColumn<int>(
    'timeout',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxFailedTimesMeta = const VerificationMeta(
    'maxFailedTimes',
  );
  @override
  late final GeneratedColumn<int> maxFailedTimes = GeneratedColumn<int>(
    'max_failed_times',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lazyMeta = const VerificationMeta('lazy');
  @override
  late final GeneratedColumn<bool> lazy = GeneratedColumn<bool>(
    'lazy',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lazy" IN (0, 1))',
    ),
  );
  static const VerificationMeta _disableUDPMeta = const VerificationMeta(
    'disableUDP',
  );
  @override
  late final GeneratedColumn<bool> disableUDP = GeneratedColumn<bool>(
    'disable_u_d_p',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("disable_u_d_p" IN (0, 1))',
    ),
  );
  static const VerificationMeta _filterMeta = const VerificationMeta('filter');
  @override
  late final GeneratedColumn<String> filter = GeneratedColumn<String>(
    'filter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludeFilterMeta = const VerificationMeta(
    'excludeFilter',
  );
  @override
  late final GeneratedColumn<String> excludeFilter = GeneratedColumn<String>(
    'exclude_filter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludeTypeMeta = const VerificationMeta(
    'excludeType',
  );
  @override
  late final GeneratedColumn<String> excludeType = GeneratedColumn<String>(
    'exclude_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedStatusMeta = const VerificationMeta(
    'expectedStatus',
  );
  @override
  late final GeneratedColumn<String> expectedStatus = GeneratedColumn<String>(
    'expected_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _includeAllMeta = const VerificationMeta(
    'includeAll',
  );
  @override
  late final GeneratedColumn<bool> includeAll = GeneratedColumn<bool>(
    'include_all',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_all" IN (0, 1))',
    ),
  );
  static const VerificationMeta _includeAllProxiesMeta = const VerificationMeta(
    'includeAllProxies',
  );
  @override
  late final GeneratedColumn<bool> includeAllProxies = GeneratedColumn<bool>(
    'include_all_proxies',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_all_proxies" IN (0, 1))',
    ),
  );
  static const VerificationMeta _includeAllProvidersMeta =
      const VerificationMeta('includeAllProviders');
  @override
  late final GeneratedColumn<bool> includeAllProviders = GeneratedColumn<bool>(
    'include_all_providers',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_all_providers" IN (0, 1))',
    ),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<String> order = GeneratedColumn<String>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    type,
    proxies,
    use,
    url,
    interval,
    timeout,
    maxFailedTimes,
    lazy,
    disableUDP,
    filter,
    excludeFilter,
    excludeType,
    expectedStatus,
    includeAll,
    includeAllProxies,
    includeAllProviders,
    hidden,
    icon,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proxy_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProxyGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('timeout')) {
      context.handle(
        _timeoutMeta,
        timeout.isAcceptableOrUnknown(data['timeout']!, _timeoutMeta),
      );
    }
    if (data.containsKey('max_failed_times')) {
      context.handle(
        _maxFailedTimesMeta,
        maxFailedTimes.isAcceptableOrUnknown(
          data['max_failed_times']!,
          _maxFailedTimesMeta,
        ),
      );
    }
    if (data.containsKey('lazy')) {
      context.handle(
        _lazyMeta,
        lazy.isAcceptableOrUnknown(data['lazy']!, _lazyMeta),
      );
    }
    if (data.containsKey('disable_u_d_p')) {
      context.handle(
        _disableUDPMeta,
        disableUDP.isAcceptableOrUnknown(
          data['disable_u_d_p']!,
          _disableUDPMeta,
        ),
      );
    }
    if (data.containsKey('filter')) {
      context.handle(
        _filterMeta,
        filter.isAcceptableOrUnknown(data['filter']!, _filterMeta),
      );
    }
    if (data.containsKey('exclude_filter')) {
      context.handle(
        _excludeFilterMeta,
        excludeFilter.isAcceptableOrUnknown(
          data['exclude_filter']!,
          _excludeFilterMeta,
        ),
      );
    }
    if (data.containsKey('exclude_type')) {
      context.handle(
        _excludeTypeMeta,
        excludeType.isAcceptableOrUnknown(
          data['exclude_type']!,
          _excludeTypeMeta,
        ),
      );
    }
    if (data.containsKey('expected_status')) {
      context.handle(
        _expectedStatusMeta,
        expectedStatus.isAcceptableOrUnknown(
          data['expected_status']!,
          _expectedStatusMeta,
        ),
      );
    }
    if (data.containsKey('include_all')) {
      context.handle(
        _includeAllMeta,
        includeAll.isAcceptableOrUnknown(data['include_all']!, _includeAllMeta),
      );
    }
    if (data.containsKey('include_all_proxies')) {
      context.handle(
        _includeAllProxiesMeta,
        includeAllProxies.isAcceptableOrUnknown(
          data['include_all_proxies']!,
          _includeAllProxiesMeta,
        ),
      );
    }
    if (data.containsKey('include_all_providers')) {
      context.handle(
        _includeAllProvidersMeta,
        includeAllProviders.isAcceptableOrUnknown(
          data['include_all_providers']!,
          _includeAllProvidersMeta,
        ),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProxyGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProxyGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      proxies: $ProxyGroupsTable.$converterproxiesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}proxies'],
        ),
      ),
      use: $ProxyGroupsTable.$converterusen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}use'],
        ),
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      ),
      timeout: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeout'],
      ),
      maxFailedTimes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_failed_times'],
      ),
      lazy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lazy'],
      ),
      disableUDP: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}disable_u_d_p'],
      ),
      filter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter'],
      ),
      excludeFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exclude_filter'],
      ),
      excludeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exclude_type'],
      ),
      expectedStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_status'],
      ),
      includeAll: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_all'],
      ),
      includeAllProxies: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_all_proxies'],
      ),
      includeAllProviders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_all_providers'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ProxyGroupsTable createAlias(String alias) {
    return $ProxyGroupsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterproxies =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterproxiesn =
      NullAwareTypeConverter.wrap($converterproxies);
  static TypeConverter<List<String>, String> $converteruse =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterusen =
      NullAwareTypeConverter.wrap($converteruse);
}

class RawProxyGroup extends DataClass implements Insertable<RawProxyGroup> {
  final int id;
  final int? profileId;
  final String name;
  final String type;
  final List<String>? proxies;
  final List<String>? use;
  final String? url;
  final int? interval;
  final int? timeout;
  final int? maxFailedTimes;
  final bool? lazy;
  final bool? disableUDP;
  final String? filter;
  final String? excludeFilter;
  final String? excludeType;
  final String? expectedStatus;
  final bool? includeAll;
  final bool? includeAllProxies;
  final bool? includeAllProviders;
  final bool? hidden;
  final String? icon;
  final String? order;
  const RawProxyGroup({
    required this.id,
    this.profileId,
    required this.name,
    required this.type,
    this.proxies,
    this.use,
    this.url,
    this.interval,
    this.timeout,
    this.maxFailedTimes,
    this.lazy,
    this.disableUDP,
    this.filter,
    this.excludeFilter,
    this.excludeType,
    this.expectedStatus,
    this.includeAll,
    this.includeAllProxies,
    this.includeAllProviders,
    this.hidden,
    this.icon,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || proxies != null) {
      map['proxies'] = Variable<String>(
        $ProxyGroupsTable.$converterproxiesn.toSql(proxies),
      );
    }
    if (!nullToAbsent || use != null) {
      map['use'] = Variable<String>(
        $ProxyGroupsTable.$converterusen.toSql(use),
      );
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || interval != null) {
      map['interval'] = Variable<int>(interval);
    }
    if (!nullToAbsent || timeout != null) {
      map['timeout'] = Variable<int>(timeout);
    }
    if (!nullToAbsent || maxFailedTimes != null) {
      map['max_failed_times'] = Variable<int>(maxFailedTimes);
    }
    if (!nullToAbsent || lazy != null) {
      map['lazy'] = Variable<bool>(lazy);
    }
    if (!nullToAbsent || disableUDP != null) {
      map['disable_u_d_p'] = Variable<bool>(disableUDP);
    }
    if (!nullToAbsent || filter != null) {
      map['filter'] = Variable<String>(filter);
    }
    if (!nullToAbsent || excludeFilter != null) {
      map['exclude_filter'] = Variable<String>(excludeFilter);
    }
    if (!nullToAbsent || excludeType != null) {
      map['exclude_type'] = Variable<String>(excludeType);
    }
    if (!nullToAbsent || expectedStatus != null) {
      map['expected_status'] = Variable<String>(expectedStatus);
    }
    if (!nullToAbsent || includeAll != null) {
      map['include_all'] = Variable<bool>(includeAll);
    }
    if (!nullToAbsent || includeAllProxies != null) {
      map['include_all_proxies'] = Variable<bool>(includeAllProxies);
    }
    if (!nullToAbsent || includeAllProviders != null) {
      map['include_all_providers'] = Variable<bool>(includeAllProviders);
    }
    if (!nullToAbsent || hidden != null) {
      map['hidden'] = Variable<bool>(hidden);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<String>(order);
    }
    return map;
  }

  ProxyGroupsCompanion toCompanion(bool nullToAbsent) {
    return ProxyGroupsCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      name: Value(name),
      type: Value(type),
      proxies: proxies == null && nullToAbsent
          ? const Value.absent()
          : Value(proxies),
      use: use == null && nullToAbsent ? const Value.absent() : Value(use),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      interval: interval == null && nullToAbsent
          ? const Value.absent()
          : Value(interval),
      timeout: timeout == null && nullToAbsent
          ? const Value.absent()
          : Value(timeout),
      maxFailedTimes: maxFailedTimes == null && nullToAbsent
          ? const Value.absent()
          : Value(maxFailedTimes),
      lazy: lazy == null && nullToAbsent ? const Value.absent() : Value(lazy),
      disableUDP: disableUDP == null && nullToAbsent
          ? const Value.absent()
          : Value(disableUDP),
      filter: filter == null && nullToAbsent
          ? const Value.absent()
          : Value(filter),
      excludeFilter: excludeFilter == null && nullToAbsent
          ? const Value.absent()
          : Value(excludeFilter),
      excludeType: excludeType == null && nullToAbsent
          ? const Value.absent()
          : Value(excludeType),
      expectedStatus: expectedStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedStatus),
      includeAll: includeAll == null && nullToAbsent
          ? const Value.absent()
          : Value(includeAll),
      includeAllProxies: includeAllProxies == null && nullToAbsent
          ? const Value.absent()
          : Value(includeAllProxies),
      includeAllProviders: includeAllProviders == null && nullToAbsent
          ? const Value.absent()
          : Value(includeAllProviders),
      hidden: hidden == null && nullToAbsent
          ? const Value.absent()
          : Value(hidden),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawProxyGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProxyGroup(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      proxies: serializer.fromJson<List<String>?>(json['proxies']),
      use: serializer.fromJson<List<String>?>(json['use']),
      url: serializer.fromJson<String?>(json['url']),
      interval: serializer.fromJson<int?>(json['interval']),
      timeout: serializer.fromJson<int?>(json['timeout']),
      maxFailedTimes: serializer.fromJson<int?>(json['maxFailedTimes']),
      lazy: serializer.fromJson<bool?>(json['lazy']),
      disableUDP: serializer.fromJson<bool?>(json['disableUDP']),
      filter: serializer.fromJson<String?>(json['filter']),
      excludeFilter: serializer.fromJson<String?>(json['excludeFilter']),
      excludeType: serializer.fromJson<String?>(json['excludeType']),
      expectedStatus: serializer.fromJson<String?>(json['expectedStatus']),
      includeAll: serializer.fromJson<bool?>(json['includeAll']),
      includeAllProxies: serializer.fromJson<bool?>(json['includeAllProxies']),
      includeAllProviders: serializer.fromJson<bool?>(
        json['includeAllProviders'],
      ),
      hidden: serializer.fromJson<bool?>(json['hidden']),
      icon: serializer.fromJson<String?>(json['icon']),
      order: serializer.fromJson<String?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'proxies': serializer.toJson<List<String>?>(proxies),
      'use': serializer.toJson<List<String>?>(use),
      'url': serializer.toJson<String?>(url),
      'interval': serializer.toJson<int?>(interval),
      'timeout': serializer.toJson<int?>(timeout),
      'maxFailedTimes': serializer.toJson<int?>(maxFailedTimes),
      'lazy': serializer.toJson<bool?>(lazy),
      'disableUDP': serializer.toJson<bool?>(disableUDP),
      'filter': serializer.toJson<String?>(filter),
      'excludeFilter': serializer.toJson<String?>(excludeFilter),
      'excludeType': serializer.toJson<String?>(excludeType),
      'expectedStatus': serializer.toJson<String?>(expectedStatus),
      'includeAll': serializer.toJson<bool?>(includeAll),
      'includeAllProxies': serializer.toJson<bool?>(includeAllProxies),
      'includeAllProviders': serializer.toJson<bool?>(includeAllProviders),
      'hidden': serializer.toJson<bool?>(hidden),
      'icon': serializer.toJson<String?>(icon),
      'order': serializer.toJson<String?>(order),
    };
  }

  RawProxyGroup copyWith({
    int? id,
    Value<int?> profileId = const Value.absent(),
    String? name,
    String? type,
    Value<List<String>?> proxies = const Value.absent(),
    Value<List<String>?> use = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<int?> interval = const Value.absent(),
    Value<int?> timeout = const Value.absent(),
    Value<int?> maxFailedTimes = const Value.absent(),
    Value<bool?> lazy = const Value.absent(),
    Value<bool?> disableUDP = const Value.absent(),
    Value<String?> filter = const Value.absent(),
    Value<String?> excludeFilter = const Value.absent(),
    Value<String?> excludeType = const Value.absent(),
    Value<String?> expectedStatus = const Value.absent(),
    Value<bool?> includeAll = const Value.absent(),
    Value<bool?> includeAllProxies = const Value.absent(),
    Value<bool?> includeAllProviders = const Value.absent(),
    Value<bool?> hidden = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> order = const Value.absent(),
  }) => RawProxyGroup(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    name: name ?? this.name,
    type: type ?? this.type,
    proxies: proxies.present ? proxies.value : this.proxies,
    use: use.present ? use.value : this.use,
    url: url.present ? url.value : this.url,
    interval: interval.present ? interval.value : this.interval,
    timeout: timeout.present ? timeout.value : this.timeout,
    maxFailedTimes: maxFailedTimes.present
        ? maxFailedTimes.value
        : this.maxFailedTimes,
    lazy: lazy.present ? lazy.value : this.lazy,
    disableUDP: disableUDP.present ? disableUDP.value : this.disableUDP,
    filter: filter.present ? filter.value : this.filter,
    excludeFilter: excludeFilter.present
        ? excludeFilter.value
        : this.excludeFilter,
    excludeType: excludeType.present ? excludeType.value : this.excludeType,
    expectedStatus: expectedStatus.present
        ? expectedStatus.value
        : this.expectedStatus,
    includeAll: includeAll.present ? includeAll.value : this.includeAll,
    includeAllProxies: includeAllProxies.present
        ? includeAllProxies.value
        : this.includeAllProxies,
    includeAllProviders: includeAllProviders.present
        ? includeAllProviders.value
        : this.includeAllProviders,
    hidden: hidden.present ? hidden.value : this.hidden,
    icon: icon.present ? icon.value : this.icon,
    order: order.present ? order.value : this.order,
  );
  RawProxyGroup copyWithCompanion(ProxyGroupsCompanion data) {
    return RawProxyGroup(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      proxies: data.proxies.present ? data.proxies.value : this.proxies,
      use: data.use.present ? data.use.value : this.use,
      url: data.url.present ? data.url.value : this.url,
      interval: data.interval.present ? data.interval.value : this.interval,
      timeout: data.timeout.present ? data.timeout.value : this.timeout,
      maxFailedTimes: data.maxFailedTimes.present
          ? data.maxFailedTimes.value
          : this.maxFailedTimes,
      lazy: data.lazy.present ? data.lazy.value : this.lazy,
      disableUDP: data.disableUDP.present
          ? data.disableUDP.value
          : this.disableUDP,
      filter: data.filter.present ? data.filter.value : this.filter,
      excludeFilter: data.excludeFilter.present
          ? data.excludeFilter.value
          : this.excludeFilter,
      excludeType: data.excludeType.present
          ? data.excludeType.value
          : this.excludeType,
      expectedStatus: data.expectedStatus.present
          ? data.expectedStatus.value
          : this.expectedStatus,
      includeAll: data.includeAll.present
          ? data.includeAll.value
          : this.includeAll,
      includeAllProxies: data.includeAllProxies.present
          ? data.includeAllProxies.value
          : this.includeAllProxies,
      includeAllProviders: data.includeAllProviders.present
          ? data.includeAllProviders.value
          : this.includeAllProviders,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      icon: data.icon.present ? data.icon.value : this.icon,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProxyGroup(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('proxies: $proxies, ')
          ..write('use: $use, ')
          ..write('url: $url, ')
          ..write('interval: $interval, ')
          ..write('timeout: $timeout, ')
          ..write('maxFailedTimes: $maxFailedTimes, ')
          ..write('lazy: $lazy, ')
          ..write('disableUDP: $disableUDP, ')
          ..write('filter: $filter, ')
          ..write('excludeFilter: $excludeFilter, ')
          ..write('excludeType: $excludeType, ')
          ..write('expectedStatus: $expectedStatus, ')
          ..write('includeAll: $includeAll, ')
          ..write('includeAllProxies: $includeAllProxies, ')
          ..write('includeAllProviders: $includeAllProviders, ')
          ..write('hidden: $hidden, ')
          ..write('icon: $icon, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    profileId,
    name,
    type,
    proxies,
    use,
    url,
    interval,
    timeout,
    maxFailedTimes,
    lazy,
    disableUDP,
    filter,
    excludeFilter,
    excludeType,
    expectedStatus,
    includeAll,
    includeAllProxies,
    includeAllProviders,
    hidden,
    icon,
    order,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProxyGroup &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.type == this.type &&
          other.proxies == this.proxies &&
          other.use == this.use &&
          other.url == this.url &&
          other.interval == this.interval &&
          other.timeout == this.timeout &&
          other.maxFailedTimes == this.maxFailedTimes &&
          other.lazy == this.lazy &&
          other.disableUDP == this.disableUDP &&
          other.filter == this.filter &&
          other.excludeFilter == this.excludeFilter &&
          other.excludeType == this.excludeType &&
          other.expectedStatus == this.expectedStatus &&
          other.includeAll == this.includeAll &&
          other.includeAllProxies == this.includeAllProxies &&
          other.includeAllProviders == this.includeAllProviders &&
          other.hidden == this.hidden &&
          other.icon == this.icon &&
          other.order == this.order);
}

class ProxyGroupsCompanion extends UpdateCompanion<RawProxyGroup> {
  final Value<int> id;
  final Value<int?> profileId;
  final Value<String> name;
  final Value<String> type;
  final Value<List<String>?> proxies;
  final Value<List<String>?> use;
  final Value<String?> url;
  final Value<int?> interval;
  final Value<int?> timeout;
  final Value<int?> maxFailedTimes;
  final Value<bool?> lazy;
  final Value<bool?> disableUDP;
  final Value<String?> filter;
  final Value<String?> excludeFilter;
  final Value<String?> excludeType;
  final Value<String?> expectedStatus;
  final Value<bool?> includeAll;
  final Value<bool?> includeAllProxies;
  final Value<bool?> includeAllProviders;
  final Value<bool?> hidden;
  final Value<String?> icon;
  final Value<String?> order;
  const ProxyGroupsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.proxies = const Value.absent(),
    this.use = const Value.absent(),
    this.url = const Value.absent(),
    this.interval = const Value.absent(),
    this.timeout = const Value.absent(),
    this.maxFailedTimes = const Value.absent(),
    this.lazy = const Value.absent(),
    this.disableUDP = const Value.absent(),
    this.filter = const Value.absent(),
    this.excludeFilter = const Value.absent(),
    this.excludeType = const Value.absent(),
    this.expectedStatus = const Value.absent(),
    this.includeAll = const Value.absent(),
    this.includeAllProxies = const Value.absent(),
    this.includeAllProviders = const Value.absent(),
    this.hidden = const Value.absent(),
    this.icon = const Value.absent(),
    this.order = const Value.absent(),
  });
  ProxyGroupsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    required String type,
    this.proxies = const Value.absent(),
    this.use = const Value.absent(),
    this.url = const Value.absent(),
    this.interval = const Value.absent(),
    this.timeout = const Value.absent(),
    this.maxFailedTimes = const Value.absent(),
    this.lazy = const Value.absent(),
    this.disableUDP = const Value.absent(),
    this.filter = const Value.absent(),
    this.excludeFilter = const Value.absent(),
    this.excludeType = const Value.absent(),
    this.expectedStatus = const Value.absent(),
    this.includeAll = const Value.absent(),
    this.includeAllProxies = const Value.absent(),
    this.includeAllProviders = const Value.absent(),
    this.hidden = const Value.absent(),
    this.icon = const Value.absent(),
    this.order = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<RawProxyGroup> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? proxies,
    Expression<String>? use,
    Expression<String>? url,
    Expression<int>? interval,
    Expression<int>? timeout,
    Expression<int>? maxFailedTimes,
    Expression<bool>? lazy,
    Expression<bool>? disableUDP,
    Expression<String>? filter,
    Expression<String>? excludeFilter,
    Expression<String>? excludeType,
    Expression<String>? expectedStatus,
    Expression<bool>? includeAll,
    Expression<bool>? includeAllProxies,
    Expression<bool>? includeAllProviders,
    Expression<bool>? hidden,
    Expression<String>? icon,
    Expression<String>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (proxies != null) 'proxies': proxies,
      if (use != null) 'use': use,
      if (url != null) 'url': url,
      if (interval != null) 'interval': interval,
      if (timeout != null) 'timeout': timeout,
      if (maxFailedTimes != null) 'max_failed_times': maxFailedTimes,
      if (lazy != null) 'lazy': lazy,
      if (disableUDP != null) 'disable_u_d_p': disableUDP,
      if (filter != null) 'filter': filter,
      if (excludeFilter != null) 'exclude_filter': excludeFilter,
      if (excludeType != null) 'exclude_type': excludeType,
      if (expectedStatus != null) 'expected_status': expectedStatus,
      if (includeAll != null) 'include_all': includeAll,
      if (includeAllProxies != null) 'include_all_proxies': includeAllProxies,
      if (includeAllProviders != null)
        'include_all_providers': includeAllProviders,
      if (hidden != null) 'hidden': hidden,
      if (icon != null) 'icon': icon,
      if (order != null) 'order': order,
    });
  }

  ProxyGroupsCompanion copyWith({
    Value<int>? id,
    Value<int?>? profileId,
    Value<String>? name,
    Value<String>? type,
    Value<List<String>?>? proxies,
    Value<List<String>?>? use,
    Value<String?>? url,
    Value<int?>? interval,
    Value<int?>? timeout,
    Value<int?>? maxFailedTimes,
    Value<bool?>? lazy,
    Value<bool?>? disableUDP,
    Value<String?>? filter,
    Value<String?>? excludeFilter,
    Value<String?>? excludeType,
    Value<String?>? expectedStatus,
    Value<bool?>? includeAll,
    Value<bool?>? includeAllProxies,
    Value<bool?>? includeAllProviders,
    Value<bool?>? hidden,
    Value<String?>? icon,
    Value<String?>? order,
  }) {
    return ProxyGroupsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      type: type ?? this.type,
      proxies: proxies ?? this.proxies,
      use: use ?? this.use,
      url: url ?? this.url,
      interval: interval ?? this.interval,
      timeout: timeout ?? this.timeout,
      maxFailedTimes: maxFailedTimes ?? this.maxFailedTimes,
      lazy: lazy ?? this.lazy,
      disableUDP: disableUDP ?? this.disableUDP,
      filter: filter ?? this.filter,
      excludeFilter: excludeFilter ?? this.excludeFilter,
      excludeType: excludeType ?? this.excludeType,
      expectedStatus: expectedStatus ?? this.expectedStatus,
      includeAll: includeAll ?? this.includeAll,
      includeAllProxies: includeAllProxies ?? this.includeAllProxies,
      includeAllProviders: includeAllProviders ?? this.includeAllProviders,
      hidden: hidden ?? this.hidden,
      icon: icon ?? this.icon,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (proxies.present) {
      map['proxies'] = Variable<String>(
        $ProxyGroupsTable.$converterproxiesn.toSql(proxies.value),
      );
    }
    if (use.present) {
      map['use'] = Variable<String>(
        $ProxyGroupsTable.$converterusen.toSql(use.value),
      );
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (timeout.present) {
      map['timeout'] = Variable<int>(timeout.value);
    }
    if (maxFailedTimes.present) {
      map['max_failed_times'] = Variable<int>(maxFailedTimes.value);
    }
    if (lazy.present) {
      map['lazy'] = Variable<bool>(lazy.value);
    }
    if (disableUDP.present) {
      map['disable_u_d_p'] = Variable<bool>(disableUDP.value);
    }
    if (filter.present) {
      map['filter'] = Variable<String>(filter.value);
    }
    if (excludeFilter.present) {
      map['exclude_filter'] = Variable<String>(excludeFilter.value);
    }
    if (excludeType.present) {
      map['exclude_type'] = Variable<String>(excludeType.value);
    }
    if (expectedStatus.present) {
      map['expected_status'] = Variable<String>(expectedStatus.value);
    }
    if (includeAll.present) {
      map['include_all'] = Variable<bool>(includeAll.value);
    }
    if (includeAllProxies.present) {
      map['include_all_proxies'] = Variable<bool>(includeAllProxies.value);
    }
    if (includeAllProviders.present) {
      map['include_all_providers'] = Variable<bool>(includeAllProviders.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (order.present) {
      map['order'] = Variable<String>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProxyGroupsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('proxies: $proxies, ')
          ..write('use: $use, ')
          ..write('url: $url, ')
          ..write('interval: $interval, ')
          ..write('timeout: $timeout, ')
          ..write('maxFailedTimes: $maxFailedTimes, ')
          ..write('lazy: $lazy, ')
          ..write('disableUDP: $disableUDP, ')
          ..write('filter: $filter, ')
          ..write('excludeFilter: $excludeFilter, ')
          ..write('excludeType: $excludeType, ')
          ..write('expectedStatus: $expectedStatus, ')
          ..write('includeAll: $includeAll, ')
          ..write('includeAllProxies: $includeAllProxies, ')
          ..write('includeAllProviders: $includeAllProviders, ')
          ..write('hidden: $hidden, ')
          ..write('icon: $icon, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $IconRecordsTable extends IconRecords
    with TableInfo<$IconRecordsTable, IconRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IconRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedMeta = const VerificationMeta(
    'lastAccessed',
  );
  @override
  late final GeneratedColumn<int> lastAccessed = GeneratedColumn<int>(
    'last_accessed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [url, lastAccessed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<IconRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_accessed')) {
      context.handle(
        _lastAccessedMeta,
        lastAccessed.isAcceptableOrUnknown(
          data['last_accessed']!,
          _lastAccessedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  IconRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IconRecord(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastAccessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed'],
      )!,
    );
  }

  @override
  $IconRecordsTable createAlias(String alias) {
    return $IconRecordsTable(attachedDatabase, alias);
  }
}

class IconRecord extends DataClass implements Insertable<IconRecord> {
  final String url;
  final int lastAccessed;
  const IconRecord({required this.url, required this.lastAccessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['last_accessed'] = Variable<int>(lastAccessed);
    return map;
  }

  IconRecordsCompanion toCompanion(bool nullToAbsent) {
    return IconRecordsCompanion(
      url: Value(url),
      lastAccessed: Value(lastAccessed),
    );
  }

  factory IconRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IconRecord(
      url: serializer.fromJson<String>(json['url']),
      lastAccessed: serializer.fromJson<int>(json['lastAccessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'lastAccessed': serializer.toJson<int>(lastAccessed),
    };
  }

  IconRecord copyWith({String? url, int? lastAccessed}) => IconRecord(
    url: url ?? this.url,
    lastAccessed: lastAccessed ?? this.lastAccessed,
  );
  IconRecord copyWithCompanion(IconRecordsCompanion data) {
    return IconRecord(
      url: data.url.present ? data.url.value : this.url,
      lastAccessed: data.lastAccessed.present
          ? data.lastAccessed.value
          : this.lastAccessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IconRecord(')
          ..write('url: $url, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, lastAccessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IconRecord &&
          other.url == this.url &&
          other.lastAccessed == this.lastAccessed);
}

class IconRecordsCompanion extends UpdateCompanion<IconRecord> {
  final Value<String> url;
  final Value<int> lastAccessed;
  final Value<int> rowid;
  const IconRecordsCompanion({
    this.url = const Value.absent(),
    this.lastAccessed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IconRecordsCompanion.insert({
    required String url,
    required int lastAccessed,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       lastAccessed = Value(lastAccessed);
  static Insertable<IconRecord> custom({
    Expression<String>? url,
    Expression<int>? lastAccessed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (lastAccessed != null) 'last_accessed': lastAccessed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IconRecordsCompanion copyWith({
    Value<String>? url,
    Value<int>? lastAccessed,
    Value<int>? rowid,
  }) {
    return IconRecordsCompanion(
      url: url ?? this.url,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastAccessed.present) {
      map['last_accessed'] = Variable<int>(lastAccessed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconRecordsCompanion(')
          ..write('url: $url, ')
          ..write('lastAccessed: $lastAccessed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrafficBillingPeriodsTable extends TrafficBillingPeriods
    with TableInfo<$TrafficBillingPeriodsTable, TrafficBillingPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrafficBillingPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, startAt, endAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traffic_billing_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrafficBillingPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrafficBillingPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrafficBillingPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TrafficBillingPeriodsTable createAlias(String alias) {
    return $TrafficBillingPeriodsTable(attachedDatabase, alias);
  }
}

class TrafficBillingPeriod extends DataClass
    implements Insertable<TrafficBillingPeriod> {
  final int id;
  final String? label;

  /// 周期开始时间（epoch millis）。
  final int startAt;

  /// 周期结束时间（epoch millis）。null 表示当前活动周期。
  final int? endAt;
  final int createdAt;
  const TrafficBillingPeriod({
    required this.id,
    this.label,
    required this.startAt,
    this.endAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['start_at'] = Variable<int>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<int>(endAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TrafficBillingPeriodsCompanion toCompanion(bool nullToAbsent) {
    return TrafficBillingPeriodsCompanion(
      id: Value(id),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      createdAt: Value(createdAt),
    );
  }

  factory TrafficBillingPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrafficBillingPeriod(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String?>(json['label']),
      startAt: serializer.fromJson<int>(json['startAt']),
      endAt: serializer.fromJson<int?>(json['endAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String?>(label),
      'startAt': serializer.toJson<int>(startAt),
      'endAt': serializer.toJson<int?>(endAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TrafficBillingPeriod copyWith({
    int? id,
    Value<String?> label = const Value.absent(),
    int? startAt,
    Value<int?> endAt = const Value.absent(),
    int? createdAt,
  }) => TrafficBillingPeriod(
    id: id ?? this.id,
    label: label.present ? label.value : this.label,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    createdAt: createdAt ?? this.createdAt,
  );
  TrafficBillingPeriod copyWithCompanion(TrafficBillingPeriodsCompanion data) {
    return TrafficBillingPeriod(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrafficBillingPeriod(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, startAt, endAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrafficBillingPeriod &&
          other.id == this.id &&
          other.label == this.label &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.createdAt == this.createdAt);
}

class TrafficBillingPeriodsCompanion
    extends UpdateCompanion<TrafficBillingPeriod> {
  final Value<int> id;
  final Value<String?> label;
  final Value<int> startAt;
  final Value<int?> endAt;
  final Value<int> createdAt;
  const TrafficBillingPeriodsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TrafficBillingPeriodsCompanion.insert({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    required int startAt,
    this.endAt = const Value.absent(),
    required int createdAt,
  }) : startAt = Value(startAt),
       createdAt = Value(createdAt);
  static Insertable<TrafficBillingPeriod> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TrafficBillingPeriodsCompanion copyWith({
    Value<int>? id,
    Value<String?>? label,
    Value<int>? startAt,
    Value<int?>? endAt,
    Value<int>? createdAt,
  }) {
    return TrafficBillingPeriodsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrafficBillingPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TrafficHourlyStatsTable extends TrafficHourlyStats
    with TableInfo<$TrafficHourlyStatsTable, TrafficHourlyStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrafficHourlyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES traffic_billing_periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _hourStartMeta = const VerificationMeta(
    'hourStart',
  );
  @override
  late final GeneratedColumn<int> hourStart = GeneratedColumn<int>(
    'hour_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appIdentifierMeta = const VerificationMeta(
    'appIdentifier',
  );
  @override
  late final GeneratedColumn<String> appIdentifier = GeneratedColumn<String>(
    'app_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nodeNameMeta = const VerificationMeta(
    'nodeName',
  );
  @override
  late final GeneratedColumn<String> nodeName = GeneratedColumn<String>(
    'node_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ruleMeta = const VerificationMeta('rule');
  @override
  late final GeneratedColumn<String> rule = GeneratedColumn<String>(
    'rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bytesUpMeta = const VerificationMeta(
    'bytesUp',
  );
  @override
  late final GeneratedColumn<int> bytesUp = GeneratedColumn<int>(
    'bytes_up',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bytesDownMeta = const VerificationMeta(
    'bytesDown',
  );
  @override
  late final GeneratedColumn<int> bytesDown = GeneratedColumn<int>(
    'bytes_down',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _multiplierMeta = const VerificationMeta(
    'multiplier',
  );
  @override
  late final GeneratedColumn<double> multiplier = GeneratedColumn<double>(
    'multiplier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _estimatedBilledBytesUpMeta =
      const VerificationMeta('estimatedBilledBytesUp');
  @override
  late final GeneratedColumn<int> estimatedBilledBytesUp = GeneratedColumn<int>(
    'estimated_billed_bytes_up',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _estimatedBilledBytesDownMeta =
      const VerificationMeta('estimatedBilledBytesDown');
  @override
  late final GeneratedColumn<int> estimatedBilledBytesDown =
      GeneratedColumn<int>(
        'estimated_billed_bytes_down',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _billedRemainderUpMeta = const VerificationMeta(
    'billedRemainderUp',
  );
  @override
  late final GeneratedColumn<int> billedRemainderUp = GeneratedColumn<int>(
    'billed_remainder_up',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _billedRemainderDownMeta =
      const VerificationMeta('billedRemainderDown');
  @override
  late final GeneratedColumn<int> billedRemainderDown = GeneratedColumn<int>(
    'billed_remainder_down',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    periodId,
    hourStart,
    appIdentifier,
    nodeName,
    domain,
    rule,
    bytesUp,
    bytesDown,
    multiplier,
    estimatedBilledBytesUp,
    estimatedBilledBytesDown,
    billedRemainderUp,
    billedRemainderDown,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traffic_hourly_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrafficHourlyStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('hour_start')) {
      context.handle(
        _hourStartMeta,
        hourStart.isAcceptableOrUnknown(data['hour_start']!, _hourStartMeta),
      );
    } else if (isInserting) {
      context.missing(_hourStartMeta);
    }
    if (data.containsKey('app_identifier')) {
      context.handle(
        _appIdentifierMeta,
        appIdentifier.isAcceptableOrUnknown(
          data['app_identifier']!,
          _appIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('node_name')) {
      context.handle(
        _nodeNameMeta,
        nodeName.isAcceptableOrUnknown(data['node_name']!, _nodeNameMeta),
      );
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    }
    if (data.containsKey('rule')) {
      context.handle(
        _ruleMeta,
        rule.isAcceptableOrUnknown(data['rule']!, _ruleMeta),
      );
    }
    if (data.containsKey('bytes_up')) {
      context.handle(
        _bytesUpMeta,
        bytesUp.isAcceptableOrUnknown(data['bytes_up']!, _bytesUpMeta),
      );
    }
    if (data.containsKey('bytes_down')) {
      context.handle(
        _bytesDownMeta,
        bytesDown.isAcceptableOrUnknown(data['bytes_down']!, _bytesDownMeta),
      );
    }
    if (data.containsKey('multiplier')) {
      context.handle(
        _multiplierMeta,
        multiplier.isAcceptableOrUnknown(data['multiplier']!, _multiplierMeta),
      );
    }
    if (data.containsKey('estimated_billed_bytes_up')) {
      context.handle(
        _estimatedBilledBytesUpMeta,
        estimatedBilledBytesUp.isAcceptableOrUnknown(
          data['estimated_billed_bytes_up']!,
          _estimatedBilledBytesUpMeta,
        ),
      );
    }
    if (data.containsKey('estimated_billed_bytes_down')) {
      context.handle(
        _estimatedBilledBytesDownMeta,
        estimatedBilledBytesDown.isAcceptableOrUnknown(
          data['estimated_billed_bytes_down']!,
          _estimatedBilledBytesDownMeta,
        ),
      );
    }
    if (data.containsKey('billed_remainder_up')) {
      context.handle(
        _billedRemainderUpMeta,
        billedRemainderUp.isAcceptableOrUnknown(
          data['billed_remainder_up']!,
          _billedRemainderUpMeta,
        ),
      );
    }
    if (data.containsKey('billed_remainder_down')) {
      context.handle(
        _billedRemainderDownMeta,
        billedRemainderDown.isAcceptableOrUnknown(
          data['billed_remainder_down']!,
          _billedRemainderDownMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    periodId,
    hourStart,
    appIdentifier,
    nodeName,
    domain,
    rule,
  };
  @override
  TrafficHourlyStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrafficHourlyStat(
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      hourStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour_start'],
      )!,
      appIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_identifier'],
      )!,
      nodeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_name'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      rule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule'],
      )!,
      bytesUp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_up'],
      )!,
      bytesDown: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_down'],
      )!,
      multiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}multiplier'],
      )!,
      estimatedBilledBytesUp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_billed_bytes_up'],
      )!,
      estimatedBilledBytesDown: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_billed_bytes_down'],
      )!,
      billedRemainderUp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billed_remainder_up'],
      )!,
      billedRemainderDown: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billed_remainder_down'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrafficHourlyStatsTable createAlias(String alias) {
    return $TrafficHourlyStatsTable(attachedDatabase, alias);
  }
}

class TrafficHourlyStat extends DataClass
    implements Insertable<TrafficHourlyStat> {
  final int periodId;

  /// 小时起始时间（epoch millis，对齐到整点）。
  final int hourStart;

  /// 应用标识。'' = 未知，'__unattributed__' = 未归因代理流量。
  final String appIdentifier;

  /// 节点名。'' = 未知。
  final String nodeName;

  /// 域名。'' = 未知。
  final String domain;

  /// 规则。'' = 未知。
  final String rule;
  final int bytesUp;
  final int bytesDown;

  /// 首次入账时倍率快照，仅用于展示。
  final double multiplier;

  /// 入账时按"本次增量上行 × 当时有效倍率"累计的预计扣量。
  final int estimatedBilledBytesUp;

  /// 入账时按"本次增量下行 × 当时有效倍率"累计的预计扣量。
  final int estimatedBilledBytesDown;

  /// 上行预计扣量毫字节余数（0–999）或 -1（不可估算）。
  final int billedRemainderUp;

  /// 下行预计扣量毫字节余数（0–999）或 -1（不可估算）。
  final int billedRemainderDown;
  final int updatedAt;
  const TrafficHourlyStat({
    required this.periodId,
    required this.hourStart,
    required this.appIdentifier,
    required this.nodeName,
    required this.domain,
    required this.rule,
    required this.bytesUp,
    required this.bytesDown,
    required this.multiplier,
    required this.estimatedBilledBytesUp,
    required this.estimatedBilledBytesDown,
    required this.billedRemainderUp,
    required this.billedRemainderDown,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period_id'] = Variable<int>(periodId);
    map['hour_start'] = Variable<int>(hourStart);
    map['app_identifier'] = Variable<String>(appIdentifier);
    map['node_name'] = Variable<String>(nodeName);
    map['domain'] = Variable<String>(domain);
    map['rule'] = Variable<String>(rule);
    map['bytes_up'] = Variable<int>(bytesUp);
    map['bytes_down'] = Variable<int>(bytesDown);
    map['multiplier'] = Variable<double>(multiplier);
    map['estimated_billed_bytes_up'] = Variable<int>(estimatedBilledBytesUp);
    map['estimated_billed_bytes_down'] = Variable<int>(
      estimatedBilledBytesDown,
    );
    map['billed_remainder_up'] = Variable<int>(billedRemainderUp);
    map['billed_remainder_down'] = Variable<int>(billedRemainderDown);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TrafficHourlyStatsCompanion toCompanion(bool nullToAbsent) {
    return TrafficHourlyStatsCompanion(
      periodId: Value(periodId),
      hourStart: Value(hourStart),
      appIdentifier: Value(appIdentifier),
      nodeName: Value(nodeName),
      domain: Value(domain),
      rule: Value(rule),
      bytesUp: Value(bytesUp),
      bytesDown: Value(bytesDown),
      multiplier: Value(multiplier),
      estimatedBilledBytesUp: Value(estimatedBilledBytesUp),
      estimatedBilledBytesDown: Value(estimatedBilledBytesDown),
      billedRemainderUp: Value(billedRemainderUp),
      billedRemainderDown: Value(billedRemainderDown),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrafficHourlyStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrafficHourlyStat(
      periodId: serializer.fromJson<int>(json['periodId']),
      hourStart: serializer.fromJson<int>(json['hourStart']),
      appIdentifier: serializer.fromJson<String>(json['appIdentifier']),
      nodeName: serializer.fromJson<String>(json['nodeName']),
      domain: serializer.fromJson<String>(json['domain']),
      rule: serializer.fromJson<String>(json['rule']),
      bytesUp: serializer.fromJson<int>(json['bytesUp']),
      bytesDown: serializer.fromJson<int>(json['bytesDown']),
      multiplier: serializer.fromJson<double>(json['multiplier']),
      estimatedBilledBytesUp: serializer.fromJson<int>(
        json['estimatedBilledBytesUp'],
      ),
      estimatedBilledBytesDown: serializer.fromJson<int>(
        json['estimatedBilledBytesDown'],
      ),
      billedRemainderUp: serializer.fromJson<int>(json['billedRemainderUp']),
      billedRemainderDown: serializer.fromJson<int>(
        json['billedRemainderDown'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'periodId': serializer.toJson<int>(periodId),
      'hourStart': serializer.toJson<int>(hourStart),
      'appIdentifier': serializer.toJson<String>(appIdentifier),
      'nodeName': serializer.toJson<String>(nodeName),
      'domain': serializer.toJson<String>(domain),
      'rule': serializer.toJson<String>(rule),
      'bytesUp': serializer.toJson<int>(bytesUp),
      'bytesDown': serializer.toJson<int>(bytesDown),
      'multiplier': serializer.toJson<double>(multiplier),
      'estimatedBilledBytesUp': serializer.toJson<int>(estimatedBilledBytesUp),
      'estimatedBilledBytesDown': serializer.toJson<int>(
        estimatedBilledBytesDown,
      ),
      'billedRemainderUp': serializer.toJson<int>(billedRemainderUp),
      'billedRemainderDown': serializer.toJson<int>(billedRemainderDown),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TrafficHourlyStat copyWith({
    int? periodId,
    int? hourStart,
    String? appIdentifier,
    String? nodeName,
    String? domain,
    String? rule,
    int? bytesUp,
    int? bytesDown,
    double? multiplier,
    int? estimatedBilledBytesUp,
    int? estimatedBilledBytesDown,
    int? billedRemainderUp,
    int? billedRemainderDown,
    int? updatedAt,
  }) => TrafficHourlyStat(
    periodId: periodId ?? this.periodId,
    hourStart: hourStart ?? this.hourStart,
    appIdentifier: appIdentifier ?? this.appIdentifier,
    nodeName: nodeName ?? this.nodeName,
    domain: domain ?? this.domain,
    rule: rule ?? this.rule,
    bytesUp: bytesUp ?? this.bytesUp,
    bytesDown: bytesDown ?? this.bytesDown,
    multiplier: multiplier ?? this.multiplier,
    estimatedBilledBytesUp:
        estimatedBilledBytesUp ?? this.estimatedBilledBytesUp,
    estimatedBilledBytesDown:
        estimatedBilledBytesDown ?? this.estimatedBilledBytesDown,
    billedRemainderUp: billedRemainderUp ?? this.billedRemainderUp,
    billedRemainderDown: billedRemainderDown ?? this.billedRemainderDown,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrafficHourlyStat copyWithCompanion(TrafficHourlyStatsCompanion data) {
    return TrafficHourlyStat(
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      hourStart: data.hourStart.present ? data.hourStart.value : this.hourStart,
      appIdentifier: data.appIdentifier.present
          ? data.appIdentifier.value
          : this.appIdentifier,
      nodeName: data.nodeName.present ? data.nodeName.value : this.nodeName,
      domain: data.domain.present ? data.domain.value : this.domain,
      rule: data.rule.present ? data.rule.value : this.rule,
      bytesUp: data.bytesUp.present ? data.bytesUp.value : this.bytesUp,
      bytesDown: data.bytesDown.present ? data.bytesDown.value : this.bytesDown,
      multiplier: data.multiplier.present
          ? data.multiplier.value
          : this.multiplier,
      estimatedBilledBytesUp: data.estimatedBilledBytesUp.present
          ? data.estimatedBilledBytesUp.value
          : this.estimatedBilledBytesUp,
      estimatedBilledBytesDown: data.estimatedBilledBytesDown.present
          ? data.estimatedBilledBytesDown.value
          : this.estimatedBilledBytesDown,
      billedRemainderUp: data.billedRemainderUp.present
          ? data.billedRemainderUp.value
          : this.billedRemainderUp,
      billedRemainderDown: data.billedRemainderDown.present
          ? data.billedRemainderDown.value
          : this.billedRemainderDown,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrafficHourlyStat(')
          ..write('periodId: $periodId, ')
          ..write('hourStart: $hourStart, ')
          ..write('appIdentifier: $appIdentifier, ')
          ..write('nodeName: $nodeName, ')
          ..write('domain: $domain, ')
          ..write('rule: $rule, ')
          ..write('bytesUp: $bytesUp, ')
          ..write('bytesDown: $bytesDown, ')
          ..write('multiplier: $multiplier, ')
          ..write('estimatedBilledBytesUp: $estimatedBilledBytesUp, ')
          ..write('estimatedBilledBytesDown: $estimatedBilledBytesDown, ')
          ..write('billedRemainderUp: $billedRemainderUp, ')
          ..write('billedRemainderDown: $billedRemainderDown, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    periodId,
    hourStart,
    appIdentifier,
    nodeName,
    domain,
    rule,
    bytesUp,
    bytesDown,
    multiplier,
    estimatedBilledBytesUp,
    estimatedBilledBytesDown,
    billedRemainderUp,
    billedRemainderDown,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrafficHourlyStat &&
          other.periodId == this.periodId &&
          other.hourStart == this.hourStart &&
          other.appIdentifier == this.appIdentifier &&
          other.nodeName == this.nodeName &&
          other.domain == this.domain &&
          other.rule == this.rule &&
          other.bytesUp == this.bytesUp &&
          other.bytesDown == this.bytesDown &&
          other.multiplier == this.multiplier &&
          other.estimatedBilledBytesUp == this.estimatedBilledBytesUp &&
          other.estimatedBilledBytesDown == this.estimatedBilledBytesDown &&
          other.billedRemainderUp == this.billedRemainderUp &&
          other.billedRemainderDown == this.billedRemainderDown &&
          other.updatedAt == this.updatedAt);
}

class TrafficHourlyStatsCompanion extends UpdateCompanion<TrafficHourlyStat> {
  final Value<int> periodId;
  final Value<int> hourStart;
  final Value<String> appIdentifier;
  final Value<String> nodeName;
  final Value<String> domain;
  final Value<String> rule;
  final Value<int> bytesUp;
  final Value<int> bytesDown;
  final Value<double> multiplier;
  final Value<int> estimatedBilledBytesUp;
  final Value<int> estimatedBilledBytesDown;
  final Value<int> billedRemainderUp;
  final Value<int> billedRemainderDown;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TrafficHourlyStatsCompanion({
    this.periodId = const Value.absent(),
    this.hourStart = const Value.absent(),
    this.appIdentifier = const Value.absent(),
    this.nodeName = const Value.absent(),
    this.domain = const Value.absent(),
    this.rule = const Value.absent(),
    this.bytesUp = const Value.absent(),
    this.bytesDown = const Value.absent(),
    this.multiplier = const Value.absent(),
    this.estimatedBilledBytesUp = const Value.absent(),
    this.estimatedBilledBytesDown = const Value.absent(),
    this.billedRemainderUp = const Value.absent(),
    this.billedRemainderDown = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrafficHourlyStatsCompanion.insert({
    required int periodId,
    required int hourStart,
    this.appIdentifier = const Value.absent(),
    this.nodeName = const Value.absent(),
    this.domain = const Value.absent(),
    this.rule = const Value.absent(),
    this.bytesUp = const Value.absent(),
    this.bytesDown = const Value.absent(),
    this.multiplier = const Value.absent(),
    this.estimatedBilledBytesUp = const Value.absent(),
    this.estimatedBilledBytesDown = const Value.absent(),
    this.billedRemainderUp = const Value.absent(),
    this.billedRemainderDown = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : periodId = Value(periodId),
       hourStart = Value(hourStart),
       updatedAt = Value(updatedAt);
  static Insertable<TrafficHourlyStat> custom({
    Expression<int>? periodId,
    Expression<int>? hourStart,
    Expression<String>? appIdentifier,
    Expression<String>? nodeName,
    Expression<String>? domain,
    Expression<String>? rule,
    Expression<int>? bytesUp,
    Expression<int>? bytesDown,
    Expression<double>? multiplier,
    Expression<int>? estimatedBilledBytesUp,
    Expression<int>? estimatedBilledBytesDown,
    Expression<int>? billedRemainderUp,
    Expression<int>? billedRemainderDown,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (periodId != null) 'period_id': periodId,
      if (hourStart != null) 'hour_start': hourStart,
      if (appIdentifier != null) 'app_identifier': appIdentifier,
      if (nodeName != null) 'node_name': nodeName,
      if (domain != null) 'domain': domain,
      if (rule != null) 'rule': rule,
      if (bytesUp != null) 'bytes_up': bytesUp,
      if (bytesDown != null) 'bytes_down': bytesDown,
      if (multiplier != null) 'multiplier': multiplier,
      if (estimatedBilledBytesUp != null)
        'estimated_billed_bytes_up': estimatedBilledBytesUp,
      if (estimatedBilledBytesDown != null)
        'estimated_billed_bytes_down': estimatedBilledBytesDown,
      if (billedRemainderUp != null) 'billed_remainder_up': billedRemainderUp,
      if (billedRemainderDown != null)
        'billed_remainder_down': billedRemainderDown,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrafficHourlyStatsCompanion copyWith({
    Value<int>? periodId,
    Value<int>? hourStart,
    Value<String>? appIdentifier,
    Value<String>? nodeName,
    Value<String>? domain,
    Value<String>? rule,
    Value<int>? bytesUp,
    Value<int>? bytesDown,
    Value<double>? multiplier,
    Value<int>? estimatedBilledBytesUp,
    Value<int>? estimatedBilledBytesDown,
    Value<int>? billedRemainderUp,
    Value<int>? billedRemainderDown,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TrafficHourlyStatsCompanion(
      periodId: periodId ?? this.periodId,
      hourStart: hourStart ?? this.hourStart,
      appIdentifier: appIdentifier ?? this.appIdentifier,
      nodeName: nodeName ?? this.nodeName,
      domain: domain ?? this.domain,
      rule: rule ?? this.rule,
      bytesUp: bytesUp ?? this.bytesUp,
      bytesDown: bytesDown ?? this.bytesDown,
      multiplier: multiplier ?? this.multiplier,
      estimatedBilledBytesUp:
          estimatedBilledBytesUp ?? this.estimatedBilledBytesUp,
      estimatedBilledBytesDown:
          estimatedBilledBytesDown ?? this.estimatedBilledBytesDown,
      billedRemainderUp: billedRemainderUp ?? this.billedRemainderUp,
      billedRemainderDown: billedRemainderDown ?? this.billedRemainderDown,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (hourStart.present) {
      map['hour_start'] = Variable<int>(hourStart.value);
    }
    if (appIdentifier.present) {
      map['app_identifier'] = Variable<String>(appIdentifier.value);
    }
    if (nodeName.present) {
      map['node_name'] = Variable<String>(nodeName.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (rule.present) {
      map['rule'] = Variable<String>(rule.value);
    }
    if (bytesUp.present) {
      map['bytes_up'] = Variable<int>(bytesUp.value);
    }
    if (bytesDown.present) {
      map['bytes_down'] = Variable<int>(bytesDown.value);
    }
    if (multiplier.present) {
      map['multiplier'] = Variable<double>(multiplier.value);
    }
    if (estimatedBilledBytesUp.present) {
      map['estimated_billed_bytes_up'] = Variable<int>(
        estimatedBilledBytesUp.value,
      );
    }
    if (estimatedBilledBytesDown.present) {
      map['estimated_billed_bytes_down'] = Variable<int>(
        estimatedBilledBytesDown.value,
      );
    }
    if (billedRemainderUp.present) {
      map['billed_remainder_up'] = Variable<int>(billedRemainderUp.value);
    }
    if (billedRemainderDown.present) {
      map['billed_remainder_down'] = Variable<int>(billedRemainderDown.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrafficHourlyStatsCompanion(')
          ..write('periodId: $periodId, ')
          ..write('hourStart: $hourStart, ')
          ..write('appIdentifier: $appIdentifier, ')
          ..write('nodeName: $nodeName, ')
          ..write('domain: $domain, ')
          ..write('rule: $rule, ')
          ..write('bytesUp: $bytesUp, ')
          ..write('bytesDown: $bytesDown, ')
          ..write('multiplier: $multiplier, ')
          ..write('estimatedBilledBytesUp: $estimatedBilledBytesUp, ')
          ..write('estimatedBilledBytesDown: $estimatedBilledBytesDown, ')
          ..write('billedRemainderUp: $billedRemainderUp, ')
          ..write('billedRemainderDown: $billedRemainderDown, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrafficNodeMultipliersTable extends TrafficNodeMultipliers
    with TableInfo<$TrafficNodeMultipliersTable, TrafficNodeMultiplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrafficNodeMultipliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nodeNameMeta = const VerificationMeta(
    'nodeName',
  );
  @override
  late final GeneratedColumn<String> nodeName = GeneratedColumn<String>(
    'node_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parsedMultiplierMeta = const VerificationMeta(
    'parsedMultiplier',
  );
  @override
  late final GeneratedColumn<double> parsedMultiplier = GeneratedColumn<double>(
    'parsed_multiplier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _manualMultiplierMeta = const VerificationMeta(
    'manualMultiplier',
  );
  @override
  late final GeneratedColumn<double> manualMultiplier = GeneratedColumn<double>(
    'manual_multiplier',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    nodeName,
    parsedMultiplier,
    manualMultiplier,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traffic_node_multipliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrafficNodeMultiplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('node_name')) {
      context.handle(
        _nodeNameMeta,
        nodeName.isAcceptableOrUnknown(data['node_name']!, _nodeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeNameMeta);
    }
    if (data.containsKey('parsed_multiplier')) {
      context.handle(
        _parsedMultiplierMeta,
        parsedMultiplier.isAcceptableOrUnknown(
          data['parsed_multiplier']!,
          _parsedMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('manual_multiplier')) {
      context.handle(
        _manualMultiplierMeta,
        manualMultiplier.isAcceptableOrUnknown(
          data['manual_multiplier']!,
          _manualMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nodeName};
  @override
  TrafficNodeMultiplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrafficNodeMultiplier(
      nodeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_name'],
      )!,
      parsedMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}parsed_multiplier'],
      )!,
      manualMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_multiplier'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrafficNodeMultipliersTable createAlias(String alias) {
    return $TrafficNodeMultipliersTable(attachedDatabase, alias);
  }
}

class TrafficNodeMultiplier extends DataClass
    implements Insertable<TrafficNodeMultiplier> {
  final String nodeName;
  final double parsedMultiplier;
  final double? manualMultiplier;
  final int updatedAt;
  const TrafficNodeMultiplier({
    required this.nodeName,
    required this.parsedMultiplier,
    this.manualMultiplier,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['node_name'] = Variable<String>(nodeName);
    map['parsed_multiplier'] = Variable<double>(parsedMultiplier);
    if (!nullToAbsent || manualMultiplier != null) {
      map['manual_multiplier'] = Variable<double>(manualMultiplier);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TrafficNodeMultipliersCompanion toCompanion(bool nullToAbsent) {
    return TrafficNodeMultipliersCompanion(
      nodeName: Value(nodeName),
      parsedMultiplier: Value(parsedMultiplier),
      manualMultiplier: manualMultiplier == null && nullToAbsent
          ? const Value.absent()
          : Value(manualMultiplier),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrafficNodeMultiplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrafficNodeMultiplier(
      nodeName: serializer.fromJson<String>(json['nodeName']),
      parsedMultiplier: serializer.fromJson<double>(json['parsedMultiplier']),
      manualMultiplier: serializer.fromJson<double?>(json['manualMultiplier']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nodeName': serializer.toJson<String>(nodeName),
      'parsedMultiplier': serializer.toJson<double>(parsedMultiplier),
      'manualMultiplier': serializer.toJson<double?>(manualMultiplier),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TrafficNodeMultiplier copyWith({
    String? nodeName,
    double? parsedMultiplier,
    Value<double?> manualMultiplier = const Value.absent(),
    int? updatedAt,
  }) => TrafficNodeMultiplier(
    nodeName: nodeName ?? this.nodeName,
    parsedMultiplier: parsedMultiplier ?? this.parsedMultiplier,
    manualMultiplier: manualMultiplier.present
        ? manualMultiplier.value
        : this.manualMultiplier,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrafficNodeMultiplier copyWithCompanion(
    TrafficNodeMultipliersCompanion data,
  ) {
    return TrafficNodeMultiplier(
      nodeName: data.nodeName.present ? data.nodeName.value : this.nodeName,
      parsedMultiplier: data.parsedMultiplier.present
          ? data.parsedMultiplier.value
          : this.parsedMultiplier,
      manualMultiplier: data.manualMultiplier.present
          ? data.manualMultiplier.value
          : this.manualMultiplier,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrafficNodeMultiplier(')
          ..write('nodeName: $nodeName, ')
          ..write('parsedMultiplier: $parsedMultiplier, ')
          ..write('manualMultiplier: $manualMultiplier, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(nodeName, parsedMultiplier, manualMultiplier, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrafficNodeMultiplier &&
          other.nodeName == this.nodeName &&
          other.parsedMultiplier == this.parsedMultiplier &&
          other.manualMultiplier == this.manualMultiplier &&
          other.updatedAt == this.updatedAt);
}

class TrafficNodeMultipliersCompanion
    extends UpdateCompanion<TrafficNodeMultiplier> {
  final Value<String> nodeName;
  final Value<double> parsedMultiplier;
  final Value<double?> manualMultiplier;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TrafficNodeMultipliersCompanion({
    this.nodeName = const Value.absent(),
    this.parsedMultiplier = const Value.absent(),
    this.manualMultiplier = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrafficNodeMultipliersCompanion.insert({
    required String nodeName,
    this.parsedMultiplier = const Value.absent(),
    this.manualMultiplier = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : nodeName = Value(nodeName),
       updatedAt = Value(updatedAt);
  static Insertable<TrafficNodeMultiplier> custom({
    Expression<String>? nodeName,
    Expression<double>? parsedMultiplier,
    Expression<double>? manualMultiplier,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nodeName != null) 'node_name': nodeName,
      if (parsedMultiplier != null) 'parsed_multiplier': parsedMultiplier,
      if (manualMultiplier != null) 'manual_multiplier': manualMultiplier,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrafficNodeMultipliersCompanion copyWith({
    Value<String>? nodeName,
    Value<double>? parsedMultiplier,
    Value<double?>? manualMultiplier,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TrafficNodeMultipliersCompanion(
      nodeName: nodeName ?? this.nodeName,
      parsedMultiplier: parsedMultiplier ?? this.parsedMultiplier,
      manualMultiplier: manualMultiplier ?? this.manualMultiplier,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nodeName.present) {
      map['node_name'] = Variable<String>(nodeName.value);
    }
    if (parsedMultiplier.present) {
      map['parsed_multiplier'] = Variable<double>(parsedMultiplier.value);
    }
    if (manualMultiplier.present) {
      map['manual_multiplier'] = Variable<double>(manualMultiplier.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrafficNodeMultipliersCompanion(')
          ..write('nodeName: $nodeName, ')
          ..write('parsedMultiplier: $parsedMultiplier, ')
          ..write('manualMultiplier: $manualMultiplier, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrafficLedgerSettingsTable extends TrafficLedgerSettings
    with TableInfo<$TrafficLedgerSettingsTable, TrafficLedgerSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrafficLedgerSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _autoCycleEnabledMeta = const VerificationMeta(
    'autoCycleEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoCycleEnabled = GeneratedColumn<bool>(
    'auto_cycle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_cycle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _billingCycleDayMeta = const VerificationMeta(
    'billingCycleDay',
  );
  @override
  late final GeneratedColumn<int> billingCycleDay = GeneratedColumn<int>(
    'billing_cycle_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _billingCycleHourMeta = const VerificationMeta(
    'billingCycleHour',
  );
  @override
  late final GeneratedColumn<int> billingCycleHour = GeneratedColumn<int>(
    'billing_cycle_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    autoCycleEnabled,
    billingCycleDay,
    billingCycleHour,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traffic_ledger_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrafficLedgerSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('auto_cycle_enabled')) {
      context.handle(
        _autoCycleEnabledMeta,
        autoCycleEnabled.isAcceptableOrUnknown(
          data['auto_cycle_enabled']!,
          _autoCycleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('billing_cycle_day')) {
      context.handle(
        _billingCycleDayMeta,
        billingCycleDay.isAcceptableOrUnknown(
          data['billing_cycle_day']!,
          _billingCycleDayMeta,
        ),
      );
    }
    if (data.containsKey('billing_cycle_hour')) {
      context.handle(
        _billingCycleHourMeta,
        billingCycleHour.isAcceptableOrUnknown(
          data['billing_cycle_hour']!,
          _billingCycleHourMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrafficLedgerSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrafficLedgerSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      autoCycleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_cycle_enabled'],
      )!,
      billingCycleDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_cycle_day'],
      )!,
      billingCycleHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_cycle_hour'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrafficLedgerSettingsTable createAlias(String alias) {
    return $TrafficLedgerSettingsTable(attachedDatabase, alias);
  }
}

class TrafficLedgerSetting extends DataClass
    implements Insertable<TrafficLedgerSetting> {
  /// 固定为 1，保证全局唯一一行。
  final int id;

  /// 是否启用自动周期切换。
  final bool autoCycleEnabled;

  /// 每月刷新日，取值范围 1–28。
  final int billingCycleDay;

  /// 刷新小时。第一版固定为 0（00:00），预留。
  final int billingCycleHour;
  final int updatedAt;
  const TrafficLedgerSetting({
    required this.id,
    required this.autoCycleEnabled,
    required this.billingCycleDay,
    required this.billingCycleHour,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['auto_cycle_enabled'] = Variable<bool>(autoCycleEnabled);
    map['billing_cycle_day'] = Variable<int>(billingCycleDay);
    map['billing_cycle_hour'] = Variable<int>(billingCycleHour);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TrafficLedgerSettingsCompanion toCompanion(bool nullToAbsent) {
    return TrafficLedgerSettingsCompanion(
      id: Value(id),
      autoCycleEnabled: Value(autoCycleEnabled),
      billingCycleDay: Value(billingCycleDay),
      billingCycleHour: Value(billingCycleHour),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrafficLedgerSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrafficLedgerSetting(
      id: serializer.fromJson<int>(json['id']),
      autoCycleEnabled: serializer.fromJson<bool>(json['autoCycleEnabled']),
      billingCycleDay: serializer.fromJson<int>(json['billingCycleDay']),
      billingCycleHour: serializer.fromJson<int>(json['billingCycleHour']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'autoCycleEnabled': serializer.toJson<bool>(autoCycleEnabled),
      'billingCycleDay': serializer.toJson<int>(billingCycleDay),
      'billingCycleHour': serializer.toJson<int>(billingCycleHour),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TrafficLedgerSetting copyWith({
    int? id,
    bool? autoCycleEnabled,
    int? billingCycleDay,
    int? billingCycleHour,
    int? updatedAt,
  }) => TrafficLedgerSetting(
    id: id ?? this.id,
    autoCycleEnabled: autoCycleEnabled ?? this.autoCycleEnabled,
    billingCycleDay: billingCycleDay ?? this.billingCycleDay,
    billingCycleHour: billingCycleHour ?? this.billingCycleHour,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrafficLedgerSetting copyWithCompanion(TrafficLedgerSettingsCompanion data) {
    return TrafficLedgerSetting(
      id: data.id.present ? data.id.value : this.id,
      autoCycleEnabled: data.autoCycleEnabled.present
          ? data.autoCycleEnabled.value
          : this.autoCycleEnabled,
      billingCycleDay: data.billingCycleDay.present
          ? data.billingCycleDay.value
          : this.billingCycleDay,
      billingCycleHour: data.billingCycleHour.present
          ? data.billingCycleHour.value
          : this.billingCycleHour,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrafficLedgerSetting(')
          ..write('id: $id, ')
          ..write('autoCycleEnabled: $autoCycleEnabled, ')
          ..write('billingCycleDay: $billingCycleDay, ')
          ..write('billingCycleHour: $billingCycleHour, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    autoCycleEnabled,
    billingCycleDay,
    billingCycleHour,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrafficLedgerSetting &&
          other.id == this.id &&
          other.autoCycleEnabled == this.autoCycleEnabled &&
          other.billingCycleDay == this.billingCycleDay &&
          other.billingCycleHour == this.billingCycleHour &&
          other.updatedAt == this.updatedAt);
}

class TrafficLedgerSettingsCompanion
    extends UpdateCompanion<TrafficLedgerSetting> {
  final Value<int> id;
  final Value<bool> autoCycleEnabled;
  final Value<int> billingCycleDay;
  final Value<int> billingCycleHour;
  final Value<int> updatedAt;
  const TrafficLedgerSettingsCompanion({
    this.id = const Value.absent(),
    this.autoCycleEnabled = const Value.absent(),
    this.billingCycleDay = const Value.absent(),
    this.billingCycleHour = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TrafficLedgerSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.autoCycleEnabled = const Value.absent(),
    this.billingCycleDay = const Value.absent(),
    this.billingCycleHour = const Value.absent(),
    required int updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<TrafficLedgerSetting> custom({
    Expression<int>? id,
    Expression<bool>? autoCycleEnabled,
    Expression<int>? billingCycleDay,
    Expression<int>? billingCycleHour,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (autoCycleEnabled != null) 'auto_cycle_enabled': autoCycleEnabled,
      if (billingCycleDay != null) 'billing_cycle_day': billingCycleDay,
      if (billingCycleHour != null) 'billing_cycle_hour': billingCycleHour,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TrafficLedgerSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? autoCycleEnabled,
    Value<int>? billingCycleDay,
    Value<int>? billingCycleHour,
    Value<int>? updatedAt,
  }) {
    return TrafficLedgerSettingsCompanion(
      id: id ?? this.id,
      autoCycleEnabled: autoCycleEnabled ?? this.autoCycleEnabled,
      billingCycleDay: billingCycleDay ?? this.billingCycleDay,
      billingCycleHour: billingCycleHour ?? this.billingCycleHour,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (autoCycleEnabled.present) {
      map['auto_cycle_enabled'] = Variable<bool>(autoCycleEnabled.value);
    }
    if (billingCycleDay.present) {
      map['billing_cycle_day'] = Variable<int>(billingCycleDay.value);
    }
    if (billingCycleHour.present) {
      map['billing_cycle_hour'] = Variable<int>(billingCycleHour.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrafficLedgerSettingsCompanion(')
          ..write('id: $id, ')
          ..write('autoCycleEnabled: $autoCycleEnabled, ')
          ..write('billingCycleDay: $billingCycleDay, ')
          ..write('billingCycleHour: $billingCycleHour, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ScriptsTable scripts = $ScriptsTable(this);
  late final $RulesTable rules = $RulesTable(this);
  late final $ProfileRuleLinksTable profileRuleLinks = $ProfileRuleLinksTable(
    this,
  );
  late final $ProxyGroupsTable proxyGroups = $ProxyGroupsTable(this);
  late final $IconRecordsTable iconRecords = $IconRecordsTable(this);
  late final $TrafficBillingPeriodsTable trafficBillingPeriods =
      $TrafficBillingPeriodsTable(this);
  late final $TrafficHourlyStatsTable trafficHourlyStats =
      $TrafficHourlyStatsTable(this);
  late final $TrafficNodeMultipliersTable trafficNodeMultipliers =
      $TrafficNodeMultipliersTable(this);
  late final $TrafficLedgerSettingsTable trafficLedgerSettings =
      $TrafficLedgerSettingsTable(this);
  late final Index idxRuleTarget = Index(
    'idx_rule_target',
    'CREATE INDEX idx_rule_target ON rules (rule_target)',
  );
  late final Index idxProfileSceneOrder = Index(
    'idx_profile_scene_order',
    'CREATE INDEX idx_profile_scene_order ON profile_rule_mapping (profile_id, scene, "order")',
  );
  late final Index idxProfileNameOrder = Index(
    'idx_profile_name_order',
    'CREATE INDEX idx_profile_name_order ON proxy_groups (profile_id, name, "order")',
  );
  late final Index lastAccessedUrl = Index(
    'last_accessed_url',
    'CREATE INDEX last_accessed_url ON icon_records (last_accessed, url)',
  );
  late final Index idxTrafficPeriodHour = Index(
    'idx_traffic_period_hour',
    'CREATE INDEX idx_traffic_period_hour ON traffic_hourly_stats (period_id, hour_start)',
  );
  late final Index idxTrafficApp = Index(
    'idx_traffic_app',
    'CREATE INDEX idx_traffic_app ON traffic_hourly_stats (period_id, app_identifier)',
  );
  late final Index idxTrafficNode = Index(
    'idx_traffic_node',
    'CREATE INDEX idx_traffic_node ON traffic_hourly_stats (period_id, node_name)',
  );
  late final ProfilesDao profilesDao = ProfilesDao(this as Database);
  late final ScriptsDao scriptsDao = ScriptsDao(this as Database);
  late final RulesDao rulesDao = RulesDao(this as Database);
  late final ProxyGroupsDao proxyGroupsDao = ProxyGroupsDao(this as Database);
  late final IconRecordsDao iconRecordsDao = IconRecordsDao(this as Database);
  late final TrafficLedgerDao trafficLedgerDao = TrafficLedgerDao(
    this as Database,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    scripts,
    rules,
    profileRuleLinks,
    proxyGroups,
    iconRecords,
    trafficBillingPeriods,
    trafficHourlyStats,
    trafficNodeMultipliers,
    trafficLedgerSettings,
    idxRuleTarget,
    idxProfileSceneOrder,
    idxProfileNameOrder,
    lastAccessedUrl,
    idxTrafficPeriodHour,
    idxTrafficApp,
    idxTrafficNode,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('profile_rule_mapping', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('profile_rule_mapping', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('proxy_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'traffic_billing_periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('traffic_hourly_stats', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String label,
      Value<String?> currentGroupName,
      required String url,
      Value<DateTime?> lastUpdateDate,
      required OverwriteType overwriteType,
      Value<int?> scriptId,
      required int autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      required bool autoUpdate,
      required Map<String, String> selectedMap,
      required Set<String> unfoldSet,
      Value<int?> order,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String?> currentGroupName,
      Value<String> url,
      Value<DateTime?> lastUpdateDate,
      Value<OverwriteType> overwriteType,
      Value<int?> scriptId,
      Value<int> autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      Value<bool> autoUpdate,
      Value<Map<String, String>> selectedMap,
      Value<Set<String>> unfoldSet,
      Value<int?> order,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$Database, $ProfilesTable, RawProfile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileRuleLinksTable, List<RawProfileRuleLink>>
  _profileRuleLinksRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.profileRuleLinks,
    aliasName: $_aliasNameGenerator(
      db.profiles.id,
      db.profileRuleLinks.profileId,
    ),
  );

  $$ProfileRuleLinksTableProcessedTableManager get profileRuleLinksRefs {
    final manager = $$ProfileRuleLinksTableTableManager(
      $_db,
      $_db.profileRuleLinks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileRuleLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProxyGroupsTable, List<RawProxyGroup>>
  _proxyGroupsRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.proxyGroups,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.proxyGroups.profileId),
  );

  $$ProxyGroupsTableProcessedTableManager get proxyGroupsRefs {
    final manager = $$ProxyGroupsTableTableManager(
      $_db,
      $_db.proxyGroups,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_proxyGroupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OverwriteType, OverwriteType, String>
  get overwriteType => $composableBuilder(
    column: $table.overwriteType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubscriptionInfo?, SubscriptionInfo, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<String>, Set<String>, String>
  get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profileRuleLinksRefs(
    Expression<bool> Function($$ProfileRuleLinksTableFilterComposer f) f,
  ) {
    final $$ProfileRuleLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableFilterComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> proxyGroupsRefs(
    Expression<bool> Function($$ProxyGroupsTableFilterComposer f) f,
  ) {
    final $$ProxyGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyGroups,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyGroupsTableFilterComposer(
            $db: $db,
            $table: $db.proxyGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overwriteType => $composableBuilder(
    column: $table.overwriteType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OverwriteType, String> get overwriteType =>
      $composableBuilder(
        column: $table.overwriteType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get scriptId =>
      $composableBuilder(column: $table.scriptId, builder: (column) => column);

  GeneratedColumn<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<String>, String> get unfoldSet =>
      $composableBuilder(column: $table.unfoldSet, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  Expression<T> profileRuleLinksRefs<T extends Object>(
    Expression<T> Function($$ProfileRuleLinksTableAnnotationComposer a) f,
  ) {
    final $$ProfileRuleLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> proxyGroupsRefs<T extends Object>(
    Expression<T> Function($$ProxyGroupsTableAnnotationComposer a) f,
  ) {
    final $$ProxyGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyGroups,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.proxyGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfilesTable,
          RawProfile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (RawProfile, $$ProfilesTableReferences),
          RawProfile,
          PrefetchHooks Function({
            bool profileRuleLinksRefs,
            bool proxyGroupsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$Database db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> currentGroupName = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                Value<OverwriteType> overwriteType = const Value.absent(),
                Value<int?> scriptId = const Value.absent(),
                Value<int> autoUpdateDurationMillis = const Value.absent(),
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                Value<bool> autoUpdate = const Value.absent(),
                Value<Map<String, String>> selectedMap = const Value.absent(),
                Value<Set<String>> unfoldSet = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                lastUpdateDate: lastUpdateDate,
                overwriteType: overwriteType,
                scriptId: scriptId,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                Value<String?> currentGroupName = const Value.absent(),
                required String url,
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                required OverwriteType overwriteType,
                Value<int?> scriptId = const Value.absent(),
                required int autoUpdateDurationMillis,
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                required bool autoUpdate,
                required Map<String, String> selectedMap,
                required Set<String> unfoldSet,
                Value<int?> order = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                lastUpdateDate: lastUpdateDate,
                overwriteType: overwriteType,
                scriptId: scriptId,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileRuleLinksRefs = false, proxyGroupsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (profileRuleLinksRefs) db.profileRuleLinks,
                    if (proxyGroupsRefs) db.proxyGroups,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (profileRuleLinksRefs)
                        await $_getPrefetchedData<
                          RawProfile,
                          $ProfilesTable,
                          RawProfileRuleLink
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileRuleLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileRuleLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (proxyGroupsRefs)
                        await $_getPrefetchedData<
                          RawProfile,
                          $ProfilesTable,
                          RawProxyGroup
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._proxyGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).proxyGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfilesTable,
      RawProfile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (RawProfile, $$ProfilesTableReferences),
      RawProfile,
      PrefetchHooks Function({bool profileRuleLinksRefs, bool proxyGroupsRefs})
    >;
typedef $$ScriptsTableCreateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      required String label,
      required DateTime lastUpdateTime,
    });
typedef $$ScriptsTableUpdateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<DateTime> lastUpdateTime,
    });

class $$ScriptsTableFilterComposer extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScriptsTableOrderingComposer
    extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScriptsTableAnnotationComposer
    extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => column,
  );
}

class $$ScriptsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ScriptsTable,
          RawScript,
          $$ScriptsTableFilterComposer,
          $$ScriptsTableOrderingComposer,
          $$ScriptsTableAnnotationComposer,
          $$ScriptsTableCreateCompanionBuilder,
          $$ScriptsTableUpdateCompanionBuilder,
          (RawScript, BaseReferences<_$Database, $ScriptsTable, RawScript>),
          RawScript,
          PrefetchHooks Function()
        > {
  $$ScriptsTableTableManager(_$Database db, $ScriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> lastUpdateTime = const Value.absent(),
              }) => ScriptsCompanion(
                id: id,
                label: label,
                lastUpdateTime: lastUpdateTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required DateTime lastUpdateTime,
              }) => ScriptsCompanion.insert(
                id: id,
                label: label,
                lastUpdateTime: lastUpdateTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ScriptsTable,
      RawScript,
      $$ScriptsTableFilterComposer,
      $$ScriptsTableOrderingComposer,
      $$ScriptsTableAnnotationComposer,
      $$ScriptsTableCreateCompanionBuilder,
      $$ScriptsTableUpdateCompanionBuilder,
      (RawScript, BaseReferences<_$Database, $ScriptsTable, RawScript>),
      RawScript,
      PrefetchHooks Function()
    >;
typedef $$RulesTableCreateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      required RuleAction ruleAction,
      Value<String?> content,
      Value<String?> ruleTarget,
      Value<String?> ruleProvider,
      Value<String?> subRule,
      Value<bool> noResolve,
      Value<bool> src,
    });
typedef $$RulesTableUpdateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      Value<RuleAction> ruleAction,
      Value<String?> content,
      Value<String?> ruleTarget,
      Value<String?> ruleProvider,
      Value<String?> subRule,
      Value<bool> noResolve,
      Value<bool> src,
    });

final class $$RulesTableReferences
    extends BaseReferences<_$Database, $RulesTable, RawRule> {
  $$RulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileRuleLinksTable, List<RawProfileRuleLink>>
  _profileRuleLinksRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.profileRuleLinks,
    aliasName: $_aliasNameGenerator(db.rules.id, db.profileRuleLinks.ruleId),
  );

  $$ProfileRuleLinksTableProcessedTableManager get profileRuleLinksRefs {
    final manager = $$ProfileRuleLinksTableTableManager(
      $_db,
      $_db.profileRuleLinks,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileRuleLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RulesTableFilterComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RuleAction, RuleAction, String>
  get ruleAction => $composableBuilder(
    column: $table.ruleAction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleTarget => $composableBuilder(
    column: $table.ruleTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleProvider => $composableBuilder(
    column: $table.ruleProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subRule => $composableBuilder(
    column: $table.subRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noResolve => $composableBuilder(
    column: $table.noResolve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profileRuleLinksRefs(
    Expression<bool> Function($$ProfileRuleLinksTableFilterComposer f) f,
  ) {
    final $$ProfileRuleLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableFilterComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableOrderingComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleAction => $composableBuilder(
    column: $table.ruleAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleTarget => $composableBuilder(
    column: $table.ruleTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleProvider => $composableBuilder(
    column: $table.ruleProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subRule => $composableBuilder(
    column: $table.subRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noResolve => $composableBuilder(
    column: $table.noResolve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulesTableAnnotationComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleAction, String> get ruleAction =>
      $composableBuilder(
        column: $table.ruleAction,
        builder: (column) => column,
      );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get ruleTarget => $composableBuilder(
    column: $table.ruleTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleProvider => $composableBuilder(
    column: $table.ruleProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subRule =>
      $composableBuilder(column: $table.subRule, builder: (column) => column);

  GeneratedColumn<bool> get noResolve =>
      $composableBuilder(column: $table.noResolve, builder: (column) => column);

  GeneratedColumn<bool> get src =>
      $composableBuilder(column: $table.src, builder: (column) => column);

  Expression<T> profileRuleLinksRefs<T extends Object>(
    Expression<T> Function($$ProfileRuleLinksTableAnnotationComposer a) f,
  ) {
    final $$ProfileRuleLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $RulesTable,
          RawRule,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (RawRule, $$RulesTableReferences),
          RawRule,
          PrefetchHooks Function({bool profileRuleLinksRefs})
        > {
  $$RulesTableTableManager(_$Database db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<RuleAction> ruleAction = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> ruleTarget = const Value.absent(),
                Value<String?> ruleProvider = const Value.absent(),
                Value<String?> subRule = const Value.absent(),
                Value<bool> noResolve = const Value.absent(),
                Value<bool> src = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                ruleAction: ruleAction,
                content: content,
                ruleTarget: ruleTarget,
                ruleProvider: ruleProvider,
                subRule: subRule,
                noResolve: noResolve,
                src: src,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required RuleAction ruleAction,
                Value<String?> content = const Value.absent(),
                Value<String?> ruleTarget = const Value.absent(),
                Value<String?> ruleProvider = const Value.absent(),
                Value<String?> subRule = const Value.absent(),
                Value<bool> noResolve = const Value.absent(),
                Value<bool> src = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                ruleAction: ruleAction,
                content: content,
                ruleTarget: ruleTarget,
                ruleProvider: ruleProvider,
                subRule: subRule,
                noResolve: noResolve,
                src: src,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RulesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profileRuleLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profileRuleLinksRefs) db.profileRuleLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profileRuleLinksRefs)
                    await $_getPrefetchedData<
                      RawRule,
                      $RulesTable,
                      RawProfileRuleLink
                    >(
                      currentTable: table,
                      referencedTable: $$RulesTableReferences
                          ._profileRuleLinksRefsTable(db),
                      managerFromTypedResult: (p0) => $$RulesTableReferences(
                        db,
                        table,
                        p0,
                      ).profileRuleLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ruleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $RulesTable,
      RawRule,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (RawRule, $$RulesTableReferences),
      RawRule,
      PrefetchHooks Function({bool profileRuleLinksRefs})
    >;
typedef $$ProfileRuleLinksTableCreateCompanionBuilder =
    ProfileRuleLinksCompanion Function({
      required String id,
      Value<int?> profileId,
      required int ruleId,
      Value<RuleScene?> scene,
      Value<String?> order,
      Value<int> rowid,
    });
typedef $$ProfileRuleLinksTableUpdateCompanionBuilder =
    ProfileRuleLinksCompanion Function({
      Value<String> id,
      Value<int?> profileId,
      Value<int> ruleId,
      Value<RuleScene?> scene,
      Value<String?> order,
      Value<int> rowid,
    });

final class $$ProfileRuleLinksTableReferences
    extends
        BaseReferences<_$Database, $ProfileRuleLinksTable, RawProfileRuleLink> {
  $$ProfileRuleLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.profileRuleLinks.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RulesTable _ruleIdTable(_$Database db) => db.rules.createAlias(
    $_aliasNameGenerator(db.profileRuleLinks.ruleId, db.rules.id),
  );

  $$RulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileRuleLinksTableFilterComposer
    extends Composer<_$Database, $ProfileRuleLinksTable> {
  $$ProfileRuleLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RuleScene?, RuleScene, String> get scene =>
      $composableBuilder(
        column: $table.scene,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableFilterComposer get ruleId {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileRuleLinksTableOrderingComposer
    extends Composer<_$Database, $ProfileRuleLinksTable> {
  $$ProfileRuleLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scene => $composableBuilder(
    column: $table.scene,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableOrderingComposer get ruleId {
    final $$RulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableOrderingComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileRuleLinksTableAnnotationComposer
    extends Composer<_$Database, $ProfileRuleLinksTable> {
  $$ProfileRuleLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleScene?, String> get scene =>
      $composableBuilder(column: $table.scene, builder: (column) => column);

  GeneratedColumn<String> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableAnnotationComposer get ruleId {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileRuleLinksTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfileRuleLinksTable,
          RawProfileRuleLink,
          $$ProfileRuleLinksTableFilterComposer,
          $$ProfileRuleLinksTableOrderingComposer,
          $$ProfileRuleLinksTableAnnotationComposer,
          $$ProfileRuleLinksTableCreateCompanionBuilder,
          $$ProfileRuleLinksTableUpdateCompanionBuilder,
          (RawProfileRuleLink, $$ProfileRuleLinksTableReferences),
          RawProfileRuleLink,
          PrefetchHooks Function({bool profileId, bool ruleId})
        > {
  $$ProfileRuleLinksTableTableManager(
    _$Database db,
    $ProfileRuleLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileRuleLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileRuleLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileRuleLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<RuleScene?> scene = const Value.absent(),
                Value<String?> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileRuleLinksCompanion(
                id: id,
                profileId: profileId,
                ruleId: ruleId,
                scene: scene,
                order: order,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> profileId = const Value.absent(),
                required int ruleId,
                Value<RuleScene?> scene = const Value.absent(),
                Value<String?> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileRuleLinksCompanion.insert(
                id: id,
                profileId: profileId,
                ruleId: ruleId,
                scene: scene,
                order: order,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileRuleLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ProfileRuleLinksTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileRuleLinksTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (ruleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ruleId,
                                referencedTable:
                                    $$ProfileRuleLinksTableReferences
                                        ._ruleIdTable(db),
                                referencedColumn:
                                    $$ProfileRuleLinksTableReferences
                                        ._ruleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileRuleLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfileRuleLinksTable,
      RawProfileRuleLink,
      $$ProfileRuleLinksTableFilterComposer,
      $$ProfileRuleLinksTableOrderingComposer,
      $$ProfileRuleLinksTableAnnotationComposer,
      $$ProfileRuleLinksTableCreateCompanionBuilder,
      $$ProfileRuleLinksTableUpdateCompanionBuilder,
      (RawProfileRuleLink, $$ProfileRuleLinksTableReferences),
      RawProfileRuleLink,
      PrefetchHooks Function({bool profileId, bool ruleId})
    >;
typedef $$ProxyGroupsTableCreateCompanionBuilder =
    ProxyGroupsCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      required String name,
      required String type,
      Value<List<String>?> proxies,
      Value<List<String>?> use,
      Value<String?> url,
      Value<int?> interval,
      Value<int?> timeout,
      Value<int?> maxFailedTimes,
      Value<bool?> lazy,
      Value<bool?> disableUDP,
      Value<String?> filter,
      Value<String?> excludeFilter,
      Value<String?> excludeType,
      Value<String?> expectedStatus,
      Value<bool?> includeAll,
      Value<bool?> includeAllProxies,
      Value<bool?> includeAllProviders,
      Value<bool?> hidden,
      Value<String?> icon,
      Value<String?> order,
    });
typedef $$ProxyGroupsTableUpdateCompanionBuilder =
    ProxyGroupsCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      Value<String> name,
      Value<String> type,
      Value<List<String>?> proxies,
      Value<List<String>?> use,
      Value<String?> url,
      Value<int?> interval,
      Value<int?> timeout,
      Value<int?> maxFailedTimes,
      Value<bool?> lazy,
      Value<bool?> disableUDP,
      Value<String?> filter,
      Value<String?> excludeFilter,
      Value<String?> excludeType,
      Value<String?> expectedStatus,
      Value<bool?> includeAll,
      Value<bool?> includeAllProxies,
      Value<bool?> includeAllProviders,
      Value<bool?> hidden,
      Value<String?> icon,
      Value<String?> order,
    });

final class $$ProxyGroupsTableReferences
    extends BaseReferences<_$Database, $ProxyGroupsTable, RawProxyGroup> {
  $$ProxyGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.proxyGroups.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProxyGroupsTableFilterComposer
    extends Composer<_$Database, $ProxyGroupsTable> {
  $$ProxyGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get proxies => $composableBuilder(
    column: $table.proxies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String> get use =>
      $composableBuilder(
        column: $table.use,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeout => $composableBuilder(
    column: $table.timeout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxFailedTimes => $composableBuilder(
    column: $table.maxFailedTimes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lazy => $composableBuilder(
    column: $table.lazy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get disableUDP => $composableBuilder(
    column: $table.disableUDP,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filter => $composableBuilder(
    column: $table.filter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excludeFilter => $composableBuilder(
    column: $table.excludeFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excludeType => $composableBuilder(
    column: $table.excludeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedStatus => $composableBuilder(
    column: $table.expectedStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeAll => $composableBuilder(
    column: $table.includeAll,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeAllProxies => $composableBuilder(
    column: $table.includeAllProxies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeAllProviders => $composableBuilder(
    column: $table.includeAllProviders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyGroupsTableOrderingComposer
    extends Composer<_$Database, $ProxyGroupsTable> {
  $$ProxyGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proxies => $composableBuilder(
    column: $table.proxies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get use => $composableBuilder(
    column: $table.use,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeout => $composableBuilder(
    column: $table.timeout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxFailedTimes => $composableBuilder(
    column: $table.maxFailedTimes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lazy => $composableBuilder(
    column: $table.lazy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get disableUDP => $composableBuilder(
    column: $table.disableUDP,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filter => $composableBuilder(
    column: $table.filter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excludeFilter => $composableBuilder(
    column: $table.excludeFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excludeType => $composableBuilder(
    column: $table.excludeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedStatus => $composableBuilder(
    column: $table.expectedStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeAll => $composableBuilder(
    column: $table.includeAll,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeAllProxies => $composableBuilder(
    column: $table.includeAllProxies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeAllProviders => $composableBuilder(
    column: $table.includeAllProviders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyGroupsTableAnnotationComposer
    extends Composer<_$Database, $ProxyGroupsTable> {
  $$ProxyGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get proxies =>
      $composableBuilder(column: $table.proxies, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get use =>
      $composableBuilder(column: $table.use, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get timeout =>
      $composableBuilder(column: $table.timeout, builder: (column) => column);

  GeneratedColumn<int> get maxFailedTimes => $composableBuilder(
    column: $table.maxFailedTimes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lazy =>
      $composableBuilder(column: $table.lazy, builder: (column) => column);

  GeneratedColumn<bool> get disableUDP => $composableBuilder(
    column: $table.disableUDP,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filter =>
      $composableBuilder(column: $table.filter, builder: (column) => column);

  GeneratedColumn<String> get excludeFilter => $composableBuilder(
    column: $table.excludeFilter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get excludeType => $composableBuilder(
    column: $table.excludeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expectedStatus => $composableBuilder(
    column: $table.expectedStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeAll => $composableBuilder(
    column: $table.includeAll,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeAllProxies => $composableBuilder(
    column: $table.includeAllProxies,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeAllProviders => $composableBuilder(
    column: $table.includeAllProviders,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyGroupsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProxyGroupsTable,
          RawProxyGroup,
          $$ProxyGroupsTableFilterComposer,
          $$ProxyGroupsTableOrderingComposer,
          $$ProxyGroupsTableAnnotationComposer,
          $$ProxyGroupsTableCreateCompanionBuilder,
          $$ProxyGroupsTableUpdateCompanionBuilder,
          (RawProxyGroup, $$ProxyGroupsTableReferences),
          RawProxyGroup,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProxyGroupsTableTableManager(_$Database db, $ProxyGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProxyGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProxyGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProxyGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<List<String>?> proxies = const Value.absent(),
                Value<List<String>?> use = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> interval = const Value.absent(),
                Value<int?> timeout = const Value.absent(),
                Value<int?> maxFailedTimes = const Value.absent(),
                Value<bool?> lazy = const Value.absent(),
                Value<bool?> disableUDP = const Value.absent(),
                Value<String?> filter = const Value.absent(),
                Value<String?> excludeFilter = const Value.absent(),
                Value<String?> excludeType = const Value.absent(),
                Value<String?> expectedStatus = const Value.absent(),
                Value<bool?> includeAll = const Value.absent(),
                Value<bool?> includeAllProxies = const Value.absent(),
                Value<bool?> includeAllProviders = const Value.absent(),
                Value<bool?> hidden = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> order = const Value.absent(),
              }) => ProxyGroupsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                type: type,
                proxies: proxies,
                use: use,
                url: url,
                interval: interval,
                timeout: timeout,
                maxFailedTimes: maxFailedTimes,
                lazy: lazy,
                disableUDP: disableUDP,
                filter: filter,
                excludeFilter: excludeFilter,
                excludeType: excludeType,
                expectedStatus: expectedStatus,
                includeAll: includeAll,
                includeAllProxies: includeAllProxies,
                includeAllProviders: includeAllProviders,
                hidden: hidden,
                icon: icon,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                required String name,
                required String type,
                Value<List<String>?> proxies = const Value.absent(),
                Value<List<String>?> use = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> interval = const Value.absent(),
                Value<int?> timeout = const Value.absent(),
                Value<int?> maxFailedTimes = const Value.absent(),
                Value<bool?> lazy = const Value.absent(),
                Value<bool?> disableUDP = const Value.absent(),
                Value<String?> filter = const Value.absent(),
                Value<String?> excludeFilter = const Value.absent(),
                Value<String?> excludeType = const Value.absent(),
                Value<String?> expectedStatus = const Value.absent(),
                Value<bool?> includeAll = const Value.absent(),
                Value<bool?> includeAllProxies = const Value.absent(),
                Value<bool?> includeAllProviders = const Value.absent(),
                Value<bool?> hidden = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> order = const Value.absent(),
              }) => ProxyGroupsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                type: type,
                proxies: proxies,
                use: use,
                url: url,
                interval: interval,
                timeout: timeout,
                maxFailedTimes: maxFailedTimes,
                lazy: lazy,
                disableUDP: disableUDP,
                filter: filter,
                excludeFilter: excludeFilter,
                excludeType: excludeType,
                expectedStatus: expectedStatus,
                includeAll: includeAll,
                includeAllProxies: includeAllProxies,
                includeAllProviders: includeAllProviders,
                hidden: hidden,
                icon: icon,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProxyGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ProxyGroupsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ProxyGroupsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProxyGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProxyGroupsTable,
      RawProxyGroup,
      $$ProxyGroupsTableFilterComposer,
      $$ProxyGroupsTableOrderingComposer,
      $$ProxyGroupsTableAnnotationComposer,
      $$ProxyGroupsTableCreateCompanionBuilder,
      $$ProxyGroupsTableUpdateCompanionBuilder,
      (RawProxyGroup, $$ProxyGroupsTableReferences),
      RawProxyGroup,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$IconRecordsTableCreateCompanionBuilder =
    IconRecordsCompanion Function({
      required String url,
      required int lastAccessed,
      Value<int> rowid,
    });
typedef $$IconRecordsTableUpdateCompanionBuilder =
    IconRecordsCompanion Function({
      Value<String> url,
      Value<int> lastAccessed,
      Value<int> rowid,
    });

class $$IconRecordsTableFilterComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IconRecordsTableOrderingComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IconRecordsTableAnnotationComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => column,
  );
}

class $$IconRecordsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $IconRecordsTable,
          IconRecord,
          $$IconRecordsTableFilterComposer,
          $$IconRecordsTableOrderingComposer,
          $$IconRecordsTableAnnotationComposer,
          $$IconRecordsTableCreateCompanionBuilder,
          $$IconRecordsTableUpdateCompanionBuilder,
          (
            IconRecord,
            BaseReferences<_$Database, $IconRecordsTable, IconRecord>,
          ),
          IconRecord,
          PrefetchHooks Function()
        > {
  $$IconRecordsTableTableManager(_$Database db, $IconRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IconRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IconRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IconRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<int> lastAccessed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IconRecordsCompanion(
                url: url,
                lastAccessed: lastAccessed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required int lastAccessed,
                Value<int> rowid = const Value.absent(),
              }) => IconRecordsCompanion.insert(
                url: url,
                lastAccessed: lastAccessed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IconRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $IconRecordsTable,
      IconRecord,
      $$IconRecordsTableFilterComposer,
      $$IconRecordsTableOrderingComposer,
      $$IconRecordsTableAnnotationComposer,
      $$IconRecordsTableCreateCompanionBuilder,
      $$IconRecordsTableUpdateCompanionBuilder,
      (IconRecord, BaseReferences<_$Database, $IconRecordsTable, IconRecord>),
      IconRecord,
      PrefetchHooks Function()
    >;
typedef $$TrafficBillingPeriodsTableCreateCompanionBuilder =
    TrafficBillingPeriodsCompanion Function({
      Value<int> id,
      Value<String?> label,
      required int startAt,
      Value<int?> endAt,
      required int createdAt,
    });
typedef $$TrafficBillingPeriodsTableUpdateCompanionBuilder =
    TrafficBillingPeriodsCompanion Function({
      Value<int> id,
      Value<String?> label,
      Value<int> startAt,
      Value<int?> endAt,
      Value<int> createdAt,
    });

final class $$TrafficBillingPeriodsTableReferences
    extends
        BaseReferences<
          _$Database,
          $TrafficBillingPeriodsTable,
          TrafficBillingPeriod
        > {
  $$TrafficBillingPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TrafficHourlyStatsTable, List<TrafficHourlyStat>>
  _trafficHourlyStatsRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.trafficHourlyStats,
    aliasName: $_aliasNameGenerator(
      db.trafficBillingPeriods.id,
      db.trafficHourlyStats.periodId,
    ),
  );

  $$TrafficHourlyStatsTableProcessedTableManager get trafficHourlyStatsRefs {
    final manager = $$TrafficHourlyStatsTableTableManager(
      $_db,
      $_db.trafficHourlyStats,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trafficHourlyStatsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrafficBillingPeriodsTableFilterComposer
    extends Composer<_$Database, $TrafficBillingPeriodsTable> {
  $$TrafficBillingPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trafficHourlyStatsRefs(
    Expression<bool> Function($$TrafficHourlyStatsTableFilterComposer f) f,
  ) {
    final $$TrafficHourlyStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trafficHourlyStats,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrafficHourlyStatsTableFilterComposer(
            $db: $db,
            $table: $db.trafficHourlyStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrafficBillingPeriodsTableOrderingComposer
    extends Composer<_$Database, $TrafficBillingPeriodsTable> {
  $$TrafficBillingPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrafficBillingPeriodsTableAnnotationComposer
    extends Composer<_$Database, $TrafficBillingPeriodsTable> {
  $$TrafficBillingPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> trafficHourlyStatsRefs<T extends Object>(
    Expression<T> Function($$TrafficHourlyStatsTableAnnotationComposer a) f,
  ) {
    final $$TrafficHourlyStatsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trafficHourlyStats,
          getReferencedColumn: (t) => t.periodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrafficHourlyStatsTableAnnotationComposer(
                $db: $db,
                $table: $db.trafficHourlyStats,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrafficBillingPeriodsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TrafficBillingPeriodsTable,
          TrafficBillingPeriod,
          $$TrafficBillingPeriodsTableFilterComposer,
          $$TrafficBillingPeriodsTableOrderingComposer,
          $$TrafficBillingPeriodsTableAnnotationComposer,
          $$TrafficBillingPeriodsTableCreateCompanionBuilder,
          $$TrafficBillingPeriodsTableUpdateCompanionBuilder,
          (TrafficBillingPeriod, $$TrafficBillingPeriodsTableReferences),
          TrafficBillingPeriod,
          PrefetchHooks Function({bool trafficHourlyStatsRefs})
        > {
  $$TrafficBillingPeriodsTableTableManager(
    _$Database db,
    $TrafficBillingPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrafficBillingPeriodsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrafficBillingPeriodsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrafficBillingPeriodsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> startAt = const Value.absent(),
                Value<int?> endAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => TrafficBillingPeriodsCompanion(
                id: id,
                label: label,
                startAt: startAt,
                endAt: endAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required int startAt,
                Value<int?> endAt = const Value.absent(),
                required int createdAt,
              }) => TrafficBillingPeriodsCompanion.insert(
                id: id,
                label: label,
                startAt: startAt,
                endAt: endAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrafficBillingPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trafficHourlyStatsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trafficHourlyStatsRefs) db.trafficHourlyStats,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trafficHourlyStatsRefs)
                    await $_getPrefetchedData<
                      TrafficBillingPeriod,
                      $TrafficBillingPeriodsTable,
                      TrafficHourlyStat
                    >(
                      currentTable: table,
                      referencedTable: $$TrafficBillingPeriodsTableReferences
                          ._trafficHourlyStatsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrafficBillingPeriodsTableReferences(
                            db,
                            table,
                            p0,
                          ).trafficHourlyStatsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.periodId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrafficBillingPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TrafficBillingPeriodsTable,
      TrafficBillingPeriod,
      $$TrafficBillingPeriodsTableFilterComposer,
      $$TrafficBillingPeriodsTableOrderingComposer,
      $$TrafficBillingPeriodsTableAnnotationComposer,
      $$TrafficBillingPeriodsTableCreateCompanionBuilder,
      $$TrafficBillingPeriodsTableUpdateCompanionBuilder,
      (TrafficBillingPeriod, $$TrafficBillingPeriodsTableReferences),
      TrafficBillingPeriod,
      PrefetchHooks Function({bool trafficHourlyStatsRefs})
    >;
typedef $$TrafficHourlyStatsTableCreateCompanionBuilder =
    TrafficHourlyStatsCompanion Function({
      required int periodId,
      required int hourStart,
      Value<String> appIdentifier,
      Value<String> nodeName,
      Value<String> domain,
      Value<String> rule,
      Value<int> bytesUp,
      Value<int> bytesDown,
      Value<double> multiplier,
      Value<int> estimatedBilledBytesUp,
      Value<int> estimatedBilledBytesDown,
      Value<int> billedRemainderUp,
      Value<int> billedRemainderDown,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TrafficHourlyStatsTableUpdateCompanionBuilder =
    TrafficHourlyStatsCompanion Function({
      Value<int> periodId,
      Value<int> hourStart,
      Value<String> appIdentifier,
      Value<String> nodeName,
      Value<String> domain,
      Value<String> rule,
      Value<int> bytesUp,
      Value<int> bytesDown,
      Value<double> multiplier,
      Value<int> estimatedBilledBytesUp,
      Value<int> estimatedBilledBytesDown,
      Value<int> billedRemainderUp,
      Value<int> billedRemainderDown,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$TrafficHourlyStatsTableReferences
    extends
        BaseReferences<
          _$Database,
          $TrafficHourlyStatsTable,
          TrafficHourlyStat
        > {
  $$TrafficHourlyStatsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrafficBillingPeriodsTable _periodIdTable(_$Database db) =>
      db.trafficBillingPeriods.createAlias(
        $_aliasNameGenerator(
          db.trafficHourlyStats.periodId,
          db.trafficBillingPeriods.id,
        ),
      );

  $$TrafficBillingPeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$TrafficBillingPeriodsTableTableManager(
      $_db,
      $_db.trafficBillingPeriods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrafficHourlyStatsTableFilterComposer
    extends Composer<_$Database, $TrafficHourlyStatsTable> {
  $$TrafficHourlyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get hourStart => $composableBuilder(
    column: $table.hourStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appIdentifier => $composableBuilder(
    column: $table.appIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeName => $composableBuilder(
    column: $table.nodeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesUp => $composableBuilder(
    column: $table.bytesUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesDown => $composableBuilder(
    column: $table.bytesDown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get multiplier => $composableBuilder(
    column: $table.multiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedBilledBytesUp => $composableBuilder(
    column: $table.estimatedBilledBytesUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedBilledBytesDown => $composableBuilder(
    column: $table.estimatedBilledBytesDown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billedRemainderUp => $composableBuilder(
    column: $table.billedRemainderUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billedRemainderDown => $composableBuilder(
    column: $table.billedRemainderDown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TrafficBillingPeriodsTableFilterComposer get periodId {
    final $$TrafficBillingPeriodsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.periodId,
          referencedTable: $db.trafficBillingPeriods,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrafficBillingPeriodsTableFilterComposer(
                $db: $db,
                $table: $db.trafficBillingPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrafficHourlyStatsTableOrderingComposer
    extends Composer<_$Database, $TrafficHourlyStatsTable> {
  $$TrafficHourlyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get hourStart => $composableBuilder(
    column: $table.hourStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appIdentifier => $composableBuilder(
    column: $table.appIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeName => $composableBuilder(
    column: $table.nodeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesUp => $composableBuilder(
    column: $table.bytesUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesDown => $composableBuilder(
    column: $table.bytesDown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get multiplier => $composableBuilder(
    column: $table.multiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedBilledBytesUp => $composableBuilder(
    column: $table.estimatedBilledBytesUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedBilledBytesDown => $composableBuilder(
    column: $table.estimatedBilledBytesDown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billedRemainderUp => $composableBuilder(
    column: $table.billedRemainderUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billedRemainderDown => $composableBuilder(
    column: $table.billedRemainderDown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrafficBillingPeriodsTableOrderingComposer get periodId {
    final $$TrafficBillingPeriodsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.periodId,
          referencedTable: $db.trafficBillingPeriods,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrafficBillingPeriodsTableOrderingComposer(
                $db: $db,
                $table: $db.trafficBillingPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrafficHourlyStatsTableAnnotationComposer
    extends Composer<_$Database, $TrafficHourlyStatsTable> {
  $$TrafficHourlyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get hourStart =>
      $composableBuilder(column: $table.hourStart, builder: (column) => column);

  GeneratedColumn<String> get appIdentifier => $composableBuilder(
    column: $table.appIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nodeName =>
      $composableBuilder(column: $table.nodeName, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get rule =>
      $composableBuilder(column: $table.rule, builder: (column) => column);

  GeneratedColumn<int> get bytesUp =>
      $composableBuilder(column: $table.bytesUp, builder: (column) => column);

  GeneratedColumn<int> get bytesDown =>
      $composableBuilder(column: $table.bytesDown, builder: (column) => column);

  GeneratedColumn<double> get multiplier => $composableBuilder(
    column: $table.multiplier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedBilledBytesUp => $composableBuilder(
    column: $table.estimatedBilledBytesUp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedBilledBytesDown => $composableBuilder(
    column: $table.estimatedBilledBytesDown,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billedRemainderUp => $composableBuilder(
    column: $table.billedRemainderUp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billedRemainderDown => $composableBuilder(
    column: $table.billedRemainderDown,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TrafficBillingPeriodsTableAnnotationComposer get periodId {
    final $$TrafficBillingPeriodsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.periodId,
          referencedTable: $db.trafficBillingPeriods,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrafficBillingPeriodsTableAnnotationComposer(
                $db: $db,
                $table: $db.trafficBillingPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrafficHourlyStatsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TrafficHourlyStatsTable,
          TrafficHourlyStat,
          $$TrafficHourlyStatsTableFilterComposer,
          $$TrafficHourlyStatsTableOrderingComposer,
          $$TrafficHourlyStatsTableAnnotationComposer,
          $$TrafficHourlyStatsTableCreateCompanionBuilder,
          $$TrafficHourlyStatsTableUpdateCompanionBuilder,
          (TrafficHourlyStat, $$TrafficHourlyStatsTableReferences),
          TrafficHourlyStat,
          PrefetchHooks Function({bool periodId})
        > {
  $$TrafficHourlyStatsTableTableManager(
    _$Database db,
    $TrafficHourlyStatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrafficHourlyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrafficHourlyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrafficHourlyStatsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> periodId = const Value.absent(),
                Value<int> hourStart = const Value.absent(),
                Value<String> appIdentifier = const Value.absent(),
                Value<String> nodeName = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> rule = const Value.absent(),
                Value<int> bytesUp = const Value.absent(),
                Value<int> bytesDown = const Value.absent(),
                Value<double> multiplier = const Value.absent(),
                Value<int> estimatedBilledBytesUp = const Value.absent(),
                Value<int> estimatedBilledBytesDown = const Value.absent(),
                Value<int> billedRemainderUp = const Value.absent(),
                Value<int> billedRemainderDown = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrafficHourlyStatsCompanion(
                periodId: periodId,
                hourStart: hourStart,
                appIdentifier: appIdentifier,
                nodeName: nodeName,
                domain: domain,
                rule: rule,
                bytesUp: bytesUp,
                bytesDown: bytesDown,
                multiplier: multiplier,
                estimatedBilledBytesUp: estimatedBilledBytesUp,
                estimatedBilledBytesDown: estimatedBilledBytesDown,
                billedRemainderUp: billedRemainderUp,
                billedRemainderDown: billedRemainderDown,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int periodId,
                required int hourStart,
                Value<String> appIdentifier = const Value.absent(),
                Value<String> nodeName = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> rule = const Value.absent(),
                Value<int> bytesUp = const Value.absent(),
                Value<int> bytesDown = const Value.absent(),
                Value<double> multiplier = const Value.absent(),
                Value<int> estimatedBilledBytesUp = const Value.absent(),
                Value<int> estimatedBilledBytesDown = const Value.absent(),
                Value<int> billedRemainderUp = const Value.absent(),
                Value<int> billedRemainderDown = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TrafficHourlyStatsCompanion.insert(
                periodId: periodId,
                hourStart: hourStart,
                appIdentifier: appIdentifier,
                nodeName: nodeName,
                domain: domain,
                rule: rule,
                bytesUp: bytesUp,
                bytesDown: bytesDown,
                multiplier: multiplier,
                estimatedBilledBytesUp: estimatedBilledBytesUp,
                estimatedBilledBytesDown: estimatedBilledBytesDown,
                billedRemainderUp: billedRemainderUp,
                billedRemainderDown: billedRemainderDown,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrafficHourlyStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.periodId,
                                referencedTable:
                                    $$TrafficHourlyStatsTableReferences
                                        ._periodIdTable(db),
                                referencedColumn:
                                    $$TrafficHourlyStatsTableReferences
                                        ._periodIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrafficHourlyStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TrafficHourlyStatsTable,
      TrafficHourlyStat,
      $$TrafficHourlyStatsTableFilterComposer,
      $$TrafficHourlyStatsTableOrderingComposer,
      $$TrafficHourlyStatsTableAnnotationComposer,
      $$TrafficHourlyStatsTableCreateCompanionBuilder,
      $$TrafficHourlyStatsTableUpdateCompanionBuilder,
      (TrafficHourlyStat, $$TrafficHourlyStatsTableReferences),
      TrafficHourlyStat,
      PrefetchHooks Function({bool periodId})
    >;
typedef $$TrafficNodeMultipliersTableCreateCompanionBuilder =
    TrafficNodeMultipliersCompanion Function({
      required String nodeName,
      Value<double> parsedMultiplier,
      Value<double?> manualMultiplier,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TrafficNodeMultipliersTableUpdateCompanionBuilder =
    TrafficNodeMultipliersCompanion Function({
      Value<String> nodeName,
      Value<double> parsedMultiplier,
      Value<double?> manualMultiplier,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$TrafficNodeMultipliersTableFilterComposer
    extends Composer<_$Database, $TrafficNodeMultipliersTable> {
  $$TrafficNodeMultipliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nodeName => $composableBuilder(
    column: $table.nodeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get parsedMultiplier => $composableBuilder(
    column: $table.parsedMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualMultiplier => $composableBuilder(
    column: $table.manualMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrafficNodeMultipliersTableOrderingComposer
    extends Composer<_$Database, $TrafficNodeMultipliersTable> {
  $$TrafficNodeMultipliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nodeName => $composableBuilder(
    column: $table.nodeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get parsedMultiplier => $composableBuilder(
    column: $table.parsedMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualMultiplier => $composableBuilder(
    column: $table.manualMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrafficNodeMultipliersTableAnnotationComposer
    extends Composer<_$Database, $TrafficNodeMultipliersTable> {
  $$TrafficNodeMultipliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nodeName =>
      $composableBuilder(column: $table.nodeName, builder: (column) => column);

  GeneratedColumn<double> get parsedMultiplier => $composableBuilder(
    column: $table.parsedMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get manualMultiplier => $composableBuilder(
    column: $table.manualMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrafficNodeMultipliersTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TrafficNodeMultipliersTable,
          TrafficNodeMultiplier,
          $$TrafficNodeMultipliersTableFilterComposer,
          $$TrafficNodeMultipliersTableOrderingComposer,
          $$TrafficNodeMultipliersTableAnnotationComposer,
          $$TrafficNodeMultipliersTableCreateCompanionBuilder,
          $$TrafficNodeMultipliersTableUpdateCompanionBuilder,
          (
            TrafficNodeMultiplier,
            BaseReferences<
              _$Database,
              $TrafficNodeMultipliersTable,
              TrafficNodeMultiplier
            >,
          ),
          TrafficNodeMultiplier,
          PrefetchHooks Function()
        > {
  $$TrafficNodeMultipliersTableTableManager(
    _$Database db,
    $TrafficNodeMultipliersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrafficNodeMultipliersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrafficNodeMultipliersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrafficNodeMultipliersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> nodeName = const Value.absent(),
                Value<double> parsedMultiplier = const Value.absent(),
                Value<double?> manualMultiplier = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrafficNodeMultipliersCompanion(
                nodeName: nodeName,
                parsedMultiplier: parsedMultiplier,
                manualMultiplier: manualMultiplier,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nodeName,
                Value<double> parsedMultiplier = const Value.absent(),
                Value<double?> manualMultiplier = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TrafficNodeMultipliersCompanion.insert(
                nodeName: nodeName,
                parsedMultiplier: parsedMultiplier,
                manualMultiplier: manualMultiplier,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrafficNodeMultipliersTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TrafficNodeMultipliersTable,
      TrafficNodeMultiplier,
      $$TrafficNodeMultipliersTableFilterComposer,
      $$TrafficNodeMultipliersTableOrderingComposer,
      $$TrafficNodeMultipliersTableAnnotationComposer,
      $$TrafficNodeMultipliersTableCreateCompanionBuilder,
      $$TrafficNodeMultipliersTableUpdateCompanionBuilder,
      (
        TrafficNodeMultiplier,
        BaseReferences<
          _$Database,
          $TrafficNodeMultipliersTable,
          TrafficNodeMultiplier
        >,
      ),
      TrafficNodeMultiplier,
      PrefetchHooks Function()
    >;
typedef $$TrafficLedgerSettingsTableCreateCompanionBuilder =
    TrafficLedgerSettingsCompanion Function({
      Value<int> id,
      Value<bool> autoCycleEnabled,
      Value<int> billingCycleDay,
      Value<int> billingCycleHour,
      required int updatedAt,
    });
typedef $$TrafficLedgerSettingsTableUpdateCompanionBuilder =
    TrafficLedgerSettingsCompanion Function({
      Value<int> id,
      Value<bool> autoCycleEnabled,
      Value<int> billingCycleDay,
      Value<int> billingCycleHour,
      Value<int> updatedAt,
    });

class $$TrafficLedgerSettingsTableFilterComposer
    extends Composer<_$Database, $TrafficLedgerSettingsTable> {
  $$TrafficLedgerSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoCycleEnabled => $composableBuilder(
    column: $table.autoCycleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingCycleDay => $composableBuilder(
    column: $table.billingCycleDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingCycleHour => $composableBuilder(
    column: $table.billingCycleHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrafficLedgerSettingsTableOrderingComposer
    extends Composer<_$Database, $TrafficLedgerSettingsTable> {
  $$TrafficLedgerSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoCycleEnabled => $composableBuilder(
    column: $table.autoCycleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingCycleDay => $composableBuilder(
    column: $table.billingCycleDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingCycleHour => $composableBuilder(
    column: $table.billingCycleHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrafficLedgerSettingsTableAnnotationComposer
    extends Composer<_$Database, $TrafficLedgerSettingsTable> {
  $$TrafficLedgerSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get autoCycleEnabled => $composableBuilder(
    column: $table.autoCycleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingCycleDay => $composableBuilder(
    column: $table.billingCycleDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingCycleHour => $composableBuilder(
    column: $table.billingCycleHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrafficLedgerSettingsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TrafficLedgerSettingsTable,
          TrafficLedgerSetting,
          $$TrafficLedgerSettingsTableFilterComposer,
          $$TrafficLedgerSettingsTableOrderingComposer,
          $$TrafficLedgerSettingsTableAnnotationComposer,
          $$TrafficLedgerSettingsTableCreateCompanionBuilder,
          $$TrafficLedgerSettingsTableUpdateCompanionBuilder,
          (
            TrafficLedgerSetting,
            BaseReferences<
              _$Database,
              $TrafficLedgerSettingsTable,
              TrafficLedgerSetting
            >,
          ),
          TrafficLedgerSetting,
          PrefetchHooks Function()
        > {
  $$TrafficLedgerSettingsTableTableManager(
    _$Database db,
    $TrafficLedgerSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrafficLedgerSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrafficLedgerSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrafficLedgerSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> autoCycleEnabled = const Value.absent(),
                Value<int> billingCycleDay = const Value.absent(),
                Value<int> billingCycleHour = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => TrafficLedgerSettingsCompanion(
                id: id,
                autoCycleEnabled: autoCycleEnabled,
                billingCycleDay: billingCycleDay,
                billingCycleHour: billingCycleHour,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> autoCycleEnabled = const Value.absent(),
                Value<int> billingCycleDay = const Value.absent(),
                Value<int> billingCycleHour = const Value.absent(),
                required int updatedAt,
              }) => TrafficLedgerSettingsCompanion.insert(
                id: id,
                autoCycleEnabled: autoCycleEnabled,
                billingCycleDay: billingCycleDay,
                billingCycleHour: billingCycleHour,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrafficLedgerSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TrafficLedgerSettingsTable,
      TrafficLedgerSetting,
      $$TrafficLedgerSettingsTableFilterComposer,
      $$TrafficLedgerSettingsTableOrderingComposer,
      $$TrafficLedgerSettingsTableAnnotationComposer,
      $$TrafficLedgerSettingsTableCreateCompanionBuilder,
      $$TrafficLedgerSettingsTableUpdateCompanionBuilder,
      (
        TrafficLedgerSetting,
        BaseReferences<
          _$Database,
          $TrafficLedgerSettingsTable,
          TrafficLedgerSetting
        >,
      ),
      TrafficLedgerSetting,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ScriptsTableTableManager get scripts =>
      $$ScriptsTableTableManager(_db, _db.scripts);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
  $$ProfileRuleLinksTableTableManager get profileRuleLinks =>
      $$ProfileRuleLinksTableTableManager(_db, _db.profileRuleLinks);
  $$ProxyGroupsTableTableManager get proxyGroups =>
      $$ProxyGroupsTableTableManager(_db, _db.proxyGroups);
  $$IconRecordsTableTableManager get iconRecords =>
      $$IconRecordsTableTableManager(_db, _db.iconRecords);
  $$TrafficBillingPeriodsTableTableManager get trafficBillingPeriods =>
      $$TrafficBillingPeriodsTableTableManager(_db, _db.trafficBillingPeriods);
  $$TrafficHourlyStatsTableTableManager get trafficHourlyStats =>
      $$TrafficHourlyStatsTableTableManager(_db, _db.trafficHourlyStats);
  $$TrafficNodeMultipliersTableTableManager get trafficNodeMultipliers =>
      $$TrafficNodeMultipliersTableTableManager(
        _db,
        _db.trafficNodeMultipliers,
      );
  $$TrafficLedgerSettingsTableTableManager get trafficLedgerSettings =>
      $$TrafficLedgerSettingsTableTableManager(_db, _db.trafficLedgerSettings);
}

mixin _$ProfilesDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  ProfilesDaoManager get managers => ProfilesDaoManager(this);
}

class ProfilesDaoManager {
  final _$ProfilesDaoMixin _db;
  ProfilesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}

mixin _$ScriptsDaoMixin on DatabaseAccessor<Database> {
  $ScriptsTable get scripts => attachedDatabase.scripts;
  ScriptsDaoManager get managers => ScriptsDaoManager(this);
}

class ScriptsDaoManager {
  final _$ScriptsDaoMixin _db;
  ScriptsDaoManager(this._db);
  $$ScriptsTableTableManager get scripts =>
      $$ScriptsTableTableManager(_db.attachedDatabase, _db.scripts);
}

mixin _$RulesDaoMixin on DatabaseAccessor<Database> {
  $RulesTable get rules => attachedDatabase.rules;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ProfileRuleLinksTable get profileRuleLinks =>
      attachedDatabase.profileRuleLinks;
  RulesDaoManager get managers => RulesDaoManager(this);
}

class RulesDaoManager {
  final _$RulesDaoMixin _db;
  RulesDaoManager(this._db);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db.attachedDatabase, _db.rules);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ProfileRuleLinksTableTableManager get profileRuleLinks =>
      $$ProfileRuleLinksTableTableManager(
        _db.attachedDatabase,
        _db.profileRuleLinks,
      );
}

mixin _$ProxyGroupsDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ProxyGroupsTable get proxyGroups => attachedDatabase.proxyGroups;
  ProxyGroupsDaoManager get managers => ProxyGroupsDaoManager(this);
}

class ProxyGroupsDaoManager {
  final _$ProxyGroupsDaoMixin _db;
  ProxyGroupsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ProxyGroupsTableTableManager get proxyGroups =>
      $$ProxyGroupsTableTableManager(_db.attachedDatabase, _db.proxyGroups);
}

mixin _$IconRecordsDaoMixin on DatabaseAccessor<Database> {
  $IconRecordsTable get iconRecords => attachedDatabase.iconRecords;
  IconRecordsDaoManager get managers => IconRecordsDaoManager(this);
}

class IconRecordsDaoManager {
  final _$IconRecordsDaoMixin _db;
  IconRecordsDaoManager(this._db);
  $$IconRecordsTableTableManager get iconRecords =>
      $$IconRecordsTableTableManager(_db.attachedDatabase, _db.iconRecords);
}

mixin _$TrafficLedgerDaoMixin on DatabaseAccessor<Database> {
  $TrafficBillingPeriodsTable get trafficBillingPeriods =>
      attachedDatabase.trafficBillingPeriods;
  $TrafficHourlyStatsTable get trafficHourlyStats =>
      attachedDatabase.trafficHourlyStats;
  $TrafficNodeMultipliersTable get trafficNodeMultipliers =>
      attachedDatabase.trafficNodeMultipliers;
  $TrafficLedgerSettingsTable get trafficLedgerSettings =>
      attachedDatabase.trafficLedgerSettings;
  TrafficLedgerDaoManager get managers => TrafficLedgerDaoManager(this);
}

class TrafficLedgerDaoManager {
  final _$TrafficLedgerDaoMixin _db;
  TrafficLedgerDaoManager(this._db);
  $$TrafficBillingPeriodsTableTableManager get trafficBillingPeriods =>
      $$TrafficBillingPeriodsTableTableManager(
        _db.attachedDatabase,
        _db.trafficBillingPeriods,
      );
  $$TrafficHourlyStatsTableTableManager get trafficHourlyStats =>
      $$TrafficHourlyStatsTableTableManager(
        _db.attachedDatabase,
        _db.trafficHourlyStats,
      );
  $$TrafficNodeMultipliersTableTableManager get trafficNodeMultipliers =>
      $$TrafficNodeMultipliersTableTableManager(
        _db.attachedDatabase,
        _db.trafficNodeMultipliers,
      );
  $$TrafficLedgerSettingsTableTableManager get trafficLedgerSettings =>
      $$TrafficLedgerSettingsTableTableManager(
        _db.attachedDatabase,
        _db.trafficLedgerSettings,
      );
}
