// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderRefMeta = const VerificationMeta(
    'orderRef',
  );
  @override
  late final GeneratedColumn<String> orderRef = GeneratedColumn<String>(
    'order_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePayMeta = const VerificationMeta(
    'basePay',
  );
  @override
  late final GeneratedColumn<double> basePay = GeneratedColumn<double>(
    'base_pay',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incentiveMeta = const VerificationMeta(
    'incentive',
  );
  @override
  late final GeneratedColumn<double> incentive = GeneratedColumn<double>(
    'incentive',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tipMeta = const VerificationMeta('tip');
  @override
  late final GeneratedColumn<double> tip = GeneratedColumn<double>(
    'tip',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceScreenshotHashMeta =
      const VerificationMeta('sourceScreenshotHash');
  @override
  late final GeneratedColumn<String> sourceScreenshotHash =
      GeneratedColumn<String>(
        'source_screenshot_hash',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _screenshotPathMeta = const VerificationMeta(
    'screenshotPath',
  );
  @override
  late final GeneratedColumn<String> screenshotPath = GeneratedColumn<String>(
    'screenshot_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    platform,
    orderRef,
    timestamp,
    basePay,
    incentive,
    tip,
    distanceKm,
    durationMin,
    zone,
    sourceScreenshotHash,
    createdAt,
    screenshotPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('order_ref')) {
      context.handle(
        _orderRefMeta,
        orderRef.isAcceptableOrUnknown(data['order_ref']!, _orderRefMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('base_pay')) {
      context.handle(
        _basePayMeta,
        basePay.isAcceptableOrUnknown(data['base_pay']!, _basePayMeta),
      );
    } else if (isInserting) {
      context.missing(_basePayMeta);
    }
    if (data.containsKey('incentive')) {
      context.handle(
        _incentiveMeta,
        incentive.isAcceptableOrUnknown(data['incentive']!, _incentiveMeta),
      );
    }
    if (data.containsKey('tip')) {
      context.handle(
        _tipMeta,
        tip.isAcceptableOrUnknown(data['tip']!, _tipMeta),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    }
    if (data.containsKey('source_screenshot_hash')) {
      context.handle(
        _sourceScreenshotHashMeta,
        sourceScreenshotHash.isAcceptableOrUnknown(
          data['source_screenshot_hash']!,
          _sourceScreenshotHashMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('screenshot_path')) {
      context.handle(
        _screenshotPathMeta,
        screenshotPath.isAcceptableOrUnknown(
          data['screenshot_path']!,
          _screenshotPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      orderRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_ref'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      basePay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_pay'],
      )!,
      incentive: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}incentive'],
      )!,
      tip: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tip'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      ),
      sourceScreenshotHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_screenshot_hash'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      screenshotPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}screenshot_path'],
      ),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final int id;
  final String platform;
  final String? orderRef;
  final DateTime timestamp;
  final double basePay;
  final double incentive;
  final double tip;
  final double? distanceKm;
  final int? durationMin;
  final String? zone;
  final String? sourceScreenshotHash;
  final DateTime createdAt;

  /// Local file path of the source screenshot, persisted at import time
  /// (Phase 6) so it can later be pulled into the Evidence Locker as
  /// rate-cut proof. Null for orders imported before Phase 6, or entered
  /// by hand.
  final String? screenshotPath;
  const Order({
    required this.id,
    required this.platform,
    this.orderRef,
    required this.timestamp,
    required this.basePay,
    required this.incentive,
    required this.tip,
    this.distanceKm,
    this.durationMin,
    this.zone,
    this.sourceScreenshotHash,
    required this.createdAt,
    this.screenshotPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || orderRef != null) {
      map['order_ref'] = Variable<String>(orderRef);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['base_pay'] = Variable<double>(basePay);
    map['incentive'] = Variable<double>(incentive);
    map['tip'] = Variable<double>(tip);
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    if (!nullToAbsent || zone != null) {
      map['zone'] = Variable<String>(zone);
    }
    if (!nullToAbsent || sourceScreenshotHash != null) {
      map['source_screenshot_hash'] = Variable<String>(sourceScreenshotHash);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || screenshotPath != null) {
      map['screenshot_path'] = Variable<String>(screenshotPath);
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      platform: Value(platform),
      orderRef: orderRef == null && nullToAbsent
          ? const Value.absent()
          : Value(orderRef),
      timestamp: Value(timestamp),
      basePay: Value(basePay),
      incentive: Value(incentive),
      tip: Value(tip),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      zone: zone == null && nullToAbsent ? const Value.absent() : Value(zone),
      sourceScreenshotHash: sourceScreenshotHash == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceScreenshotHash),
      createdAt: Value(createdAt),
      screenshotPath: screenshotPath == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotPath),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<int>(json['id']),
      platform: serializer.fromJson<String>(json['platform']),
      orderRef: serializer.fromJson<String?>(json['orderRef']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      basePay: serializer.fromJson<double>(json['basePay']),
      incentive: serializer.fromJson<double>(json['incentive']),
      tip: serializer.fromJson<double>(json['tip']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      zone: serializer.fromJson<String?>(json['zone']),
      sourceScreenshotHash: serializer.fromJson<String?>(
        json['sourceScreenshotHash'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      screenshotPath: serializer.fromJson<String?>(json['screenshotPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'platform': serializer.toJson<String>(platform),
      'orderRef': serializer.toJson<String?>(orderRef),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'basePay': serializer.toJson<double>(basePay),
      'incentive': serializer.toJson<double>(incentive),
      'tip': serializer.toJson<double>(tip),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'durationMin': serializer.toJson<int?>(durationMin),
      'zone': serializer.toJson<String?>(zone),
      'sourceScreenshotHash': serializer.toJson<String?>(sourceScreenshotHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'screenshotPath': serializer.toJson<String?>(screenshotPath),
    };
  }

  Order copyWith({
    int? id,
    String? platform,
    Value<String?> orderRef = const Value.absent(),
    DateTime? timestamp,
    double? basePay,
    double? incentive,
    double? tip,
    Value<double?> distanceKm = const Value.absent(),
    Value<int?> durationMin = const Value.absent(),
    Value<String?> zone = const Value.absent(),
    Value<String?> sourceScreenshotHash = const Value.absent(),
    DateTime? createdAt,
    Value<String?> screenshotPath = const Value.absent(),
  }) => Order(
    id: id ?? this.id,
    platform: platform ?? this.platform,
    orderRef: orderRef.present ? orderRef.value : this.orderRef,
    timestamp: timestamp ?? this.timestamp,
    basePay: basePay ?? this.basePay,
    incentive: incentive ?? this.incentive,
    tip: tip ?? this.tip,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    zone: zone.present ? zone.value : this.zone,
    sourceScreenshotHash: sourceScreenshotHash.present
        ? sourceScreenshotHash.value
        : this.sourceScreenshotHash,
    createdAt: createdAt ?? this.createdAt,
    screenshotPath: screenshotPath.present
        ? screenshotPath.value
        : this.screenshotPath,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      platform: data.platform.present ? data.platform.value : this.platform,
      orderRef: data.orderRef.present ? data.orderRef.value : this.orderRef,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      basePay: data.basePay.present ? data.basePay.value : this.basePay,
      incentive: data.incentive.present ? data.incentive.value : this.incentive,
      tip: data.tip.present ? data.tip.value : this.tip,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      zone: data.zone.present ? data.zone.value : this.zone,
      sourceScreenshotHash: data.sourceScreenshotHash.present
          ? data.sourceScreenshotHash.value
          : this.sourceScreenshotHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      screenshotPath: data.screenshotPath.present
          ? data.screenshotPath.value
          : this.screenshotPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('platform: $platform, ')
          ..write('orderRef: $orderRef, ')
          ..write('timestamp: $timestamp, ')
          ..write('basePay: $basePay, ')
          ..write('incentive: $incentive, ')
          ..write('tip: $tip, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationMin: $durationMin, ')
          ..write('zone: $zone, ')
          ..write('sourceScreenshotHash: $sourceScreenshotHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('screenshotPath: $screenshotPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    platform,
    orderRef,
    timestamp,
    basePay,
    incentive,
    tip,
    distanceKm,
    durationMin,
    zone,
    sourceScreenshotHash,
    createdAt,
    screenshotPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.platform == this.platform &&
          other.orderRef == this.orderRef &&
          other.timestamp == this.timestamp &&
          other.basePay == this.basePay &&
          other.incentive == this.incentive &&
          other.tip == this.tip &&
          other.distanceKm == this.distanceKm &&
          other.durationMin == this.durationMin &&
          other.zone == this.zone &&
          other.sourceScreenshotHash == this.sourceScreenshotHash &&
          other.createdAt == this.createdAt &&
          other.screenshotPath == this.screenshotPath);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<int> id;
  final Value<String> platform;
  final Value<String?> orderRef;
  final Value<DateTime> timestamp;
  final Value<double> basePay;
  final Value<double> incentive;
  final Value<double> tip;
  final Value<double?> distanceKm;
  final Value<int?> durationMin;
  final Value<String?> zone;
  final Value<String?> sourceScreenshotHash;
  final Value<DateTime> createdAt;
  final Value<String?> screenshotPath;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.platform = const Value.absent(),
    this.orderRef = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.basePay = const Value.absent(),
    this.incentive = const Value.absent(),
    this.tip = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.zone = const Value.absent(),
    this.sourceScreenshotHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.screenshotPath = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    required String platform,
    this.orderRef = const Value.absent(),
    required DateTime timestamp,
    required double basePay,
    this.incentive = const Value.absent(),
    this.tip = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.zone = const Value.absent(),
    this.sourceScreenshotHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.screenshotPath = const Value.absent(),
  }) : platform = Value(platform),
       timestamp = Value(timestamp),
       basePay = Value(basePay);
  static Insertable<Order> custom({
    Expression<int>? id,
    Expression<String>? platform,
    Expression<String>? orderRef,
    Expression<DateTime>? timestamp,
    Expression<double>? basePay,
    Expression<double>? incentive,
    Expression<double>? tip,
    Expression<double>? distanceKm,
    Expression<int>? durationMin,
    Expression<String>? zone,
    Expression<String>? sourceScreenshotHash,
    Expression<DateTime>? createdAt,
    Expression<String>? screenshotPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (platform != null) 'platform': platform,
      if (orderRef != null) 'order_ref': orderRef,
      if (timestamp != null) 'timestamp': timestamp,
      if (basePay != null) 'base_pay': basePay,
      if (incentive != null) 'incentive': incentive,
      if (tip != null) 'tip': tip,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (durationMin != null) 'duration_min': durationMin,
      if (zone != null) 'zone': zone,
      if (sourceScreenshotHash != null)
        'source_screenshot_hash': sourceScreenshotHash,
      if (createdAt != null) 'created_at': createdAt,
      if (screenshotPath != null) 'screenshot_path': screenshotPath,
    });
  }

  OrdersCompanion copyWith({
    Value<int>? id,
    Value<String>? platform,
    Value<String?>? orderRef,
    Value<DateTime>? timestamp,
    Value<double>? basePay,
    Value<double>? incentive,
    Value<double>? tip,
    Value<double?>? distanceKm,
    Value<int?>? durationMin,
    Value<String?>? zone,
    Value<String?>? sourceScreenshotHash,
    Value<DateTime>? createdAt,
    Value<String?>? screenshotPath,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      orderRef: orderRef ?? this.orderRef,
      timestamp: timestamp ?? this.timestamp,
      basePay: basePay ?? this.basePay,
      incentive: incentive ?? this.incentive,
      tip: tip ?? this.tip,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      zone: zone ?? this.zone,
      sourceScreenshotHash: sourceScreenshotHash ?? this.sourceScreenshotHash,
      createdAt: createdAt ?? this.createdAt,
      screenshotPath: screenshotPath ?? this.screenshotPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (orderRef.present) {
      map['order_ref'] = Variable<String>(orderRef.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (basePay.present) {
      map['base_pay'] = Variable<double>(basePay.value);
    }
    if (incentive.present) {
      map['incentive'] = Variable<double>(incentive.value);
    }
    if (tip.present) {
      map['tip'] = Variable<double>(tip.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (sourceScreenshotHash.present) {
      map['source_screenshot_hash'] = Variable<String>(
        sourceScreenshotHash.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (screenshotPath.present) {
      map['screenshot_path'] = Variable<String>(screenshotPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('platform: $platform, ')
          ..write('orderRef: $orderRef, ')
          ..write('timestamp: $timestamp, ')
          ..write('basePay: $basePay, ')
          ..write('incentive: $incentive, ')
          ..write('tip: $tip, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationMin: $durationMin, ')
          ..write('zone: $zone, ')
          ..write('sourceScreenshotHash: $sourceScreenshotHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('screenshotPath: $screenshotPath')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    amount,
    rawText,
    timestamp,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String category;
  final double amount;
  final String? rawText;
  final DateTime timestamp;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.rawText,
    required this.timestamp,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      category: Value(category),
      amount: Value(amount),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      timestamp: Value(timestamp),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'rawText': serializer.toJson<String?>(rawText),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    int? id,
    String? category,
    double? amount,
    Value<String?> rawText = const Value.absent(),
    DateTime? timestamp,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    rawText: rawText.present ? rawText.value : this.rawText,
    timestamp: timestamp ?? this.timestamp,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('rawText: $rawText, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, category, amount, rawText, timestamp, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.rawText == this.rawText &&
          other.timestamp == this.timestamp &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String> category;
  final Value<double> amount;
  final Value<String?> rawText;
  final Value<DateTime> timestamp;
  final Value<DateTime> createdAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.rawText = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required double amount,
    this.rawText = const Value.absent(),
    required DateTime timestamp,
    this.createdAt = const Value.absent(),
  }) : category = Value(category),
       amount = Value(amount),
       timestamp = Value(timestamp);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? rawText,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (rawText != null) 'raw_text': rawText,
      if (timestamp != null) 'timestamp': timestamp,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<double>? amount,
    Value<String?>? rawText,
    Value<DateTime>? timestamp,
    Value<DateTime>? createdAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      rawText: rawText ?? this.rawText,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('rawText: $rawText, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EvidenceItemsTable extends EvidenceItems
    with TableInfo<$EvidenceItemsTable, EvidenceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileHashMeta = const VerificationMeta(
    'fileHash',
  );
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
    'file_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    filePath,
    fileHash,
    capturedAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidenceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_hash')) {
      context.handle(
        _fileHashMeta,
        fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta),
      );
    } else if (isInserting) {
      context.missing(_fileHashMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvidenceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_hash'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EvidenceItemsTable createAlias(String alias) {
    return $EvidenceItemsTable(attachedDatabase, alias);
  }
}

class EvidenceItem extends DataClass implements Insertable<EvidenceItem> {
  final int id;
  final String type;
  final String filePath;
  final String fileHash;
  final DateTime capturedAt;
  final String? notes;
  final DateTime createdAt;
  const EvidenceItem({
    required this.id,
    required this.type,
    required this.filePath,
    required this.fileHash,
    required this.capturedAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['file_path'] = Variable<String>(filePath);
    map['file_hash'] = Variable<String>(fileHash);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EvidenceItemsCompanion toCompanion(bool nullToAbsent) {
    return EvidenceItemsCompanion(
      id: Value(id),
      type: Value(type),
      filePath: Value(filePath),
      fileHash: Value(fileHash),
      capturedAt: Value(capturedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory EvidenceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceItem(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileHash: serializer.fromJson<String>(json['fileHash']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String>(filePath),
      'fileHash': serializer.toJson<String>(fileHash),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EvidenceItem copyWith({
    int? id,
    String? type,
    String? filePath,
    String? fileHash,
    DateTime? capturedAt,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => EvidenceItem(
    id: id ?? this.id,
    type: type ?? this.type,
    filePath: filePath ?? this.filePath,
    fileHash: fileHash ?? this.fileHash,
    capturedAt: capturedAt ?? this.capturedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  EvidenceItem copyWithCompanion(EvidenceItemsCompanion data) {
    return EvidenceItem(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceItem(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('fileHash: $fileHash, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, filePath, fileHash, capturedAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceItem &&
          other.id == this.id &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.fileHash == this.fileHash &&
          other.capturedAt == this.capturedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EvidenceItemsCompanion extends UpdateCompanion<EvidenceItem> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> filePath;
  final Value<String> fileHash;
  final Value<DateTime> capturedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const EvidenceItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EvidenceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String filePath,
    required String fileHash,
    required DateTime capturedAt,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       filePath = Value(filePath),
       fileHash = Value(fileHash),
       capturedAt = Value(capturedAt);
  static Insertable<EvidenceItem> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<String>? fileHash,
    Expression<DateTime>? capturedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (fileHash != null) 'file_hash': fileHash,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EvidenceItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? filePath,
    Value<String>? fileHash,
    Value<DateTime>? capturedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return EvidenceItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileHash: fileHash ?? this.fileHash,
      capturedAt: capturedAt ?? this.capturedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('fileHash: $fileHash, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $EvidenceItemsTable evidenceItems = $EvidenceItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    orders,
    expenses,
    evidenceItems,
  ];
}

typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  required String platform,
  Value<String?> orderRef,
  required DateTime timestamp,
  required double basePay,
  Value<double> incentive,
  Value<double> tip,
  Value<double?> distanceKm,
  Value<int?> durationMin,
  Value<String?> zone,
  Value<String?> sourceScreenshotHash,
  Value<DateTime> createdAt,
  Value<String?> screenshotPath,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<String> platform,
  Value<String?> orderRef,
  Value<DateTime> timestamp,
  Value<double> basePay,
  Value<double> incentive,
  Value<double> tip,
  Value<double?> distanceKm,
  Value<int?> durationMin,
  Value<String?> zone,
  Value<String?> sourceScreenshotHash,
  Value<DateTime> createdAt,
  Value<String?> screenshotPath,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
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

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderRef => $composableBuilder(
    column: $table.orderRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basePay => $composableBuilder(
    column: $table.basePay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get incentive => $composableBuilder(
    column: $table.incentive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tip => $composableBuilder(
    column: $table.tip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceScreenshotHash => $composableBuilder(
    column: $table.sourceScreenshotHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screenshotPath => $composableBuilder(
    column: $table.screenshotPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
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

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderRef => $composableBuilder(
    column: $table.orderRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basePay => $composableBuilder(
    column: $table.basePay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get incentive => $composableBuilder(
    column: $table.incentive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tip => $composableBuilder(
    column: $table.tip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceScreenshotHash => $composableBuilder(
    column: $table.sourceScreenshotHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screenshotPath => $composableBuilder(
    column: $table.screenshotPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get orderRef =>
      $composableBuilder(column: $table.orderRef, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get basePay =>
      $composableBuilder(column: $table.basePay, builder: (column) => column);

  GeneratedColumn<double> get incentive =>
      $composableBuilder(column: $table.incentive, builder: (column) => column);

  GeneratedColumn<double> get tip =>
      $composableBuilder(column: $table.tip, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<String> get sourceScreenshotHash => $composableBuilder(
    column: $table.sourceScreenshotHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get screenshotPath => $composableBuilder(
    column: $table.screenshotPath,
    builder: (column) => column,
  );
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
          Order,
          PrefetchHooks Function()
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> orderRef = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> basePay = const Value.absent(),
                Value<double> incentive = const Value.absent(),
                Value<double> tip = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<String?> sourceScreenshotHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> screenshotPath = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                platform: platform,
                orderRef: orderRef,
                timestamp: timestamp,
                basePay: basePay,
                incentive: incentive,
                tip: tip,
                distanceKm: distanceKm,
                durationMin: durationMin,
                zone: zone,
                sourceScreenshotHash: sourceScreenshotHash,
                createdAt: createdAt,
                screenshotPath: screenshotPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String platform,
                Value<String?> orderRef = const Value.absent(),
                required DateTime timestamp,
                required double basePay,
                Value<double> incentive = const Value.absent(),
                Value<double> tip = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<String?> sourceScreenshotHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> screenshotPath = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                platform: platform,
                orderRef: orderRef,
                timestamp: timestamp,
                basePay: basePay,
                incentive: incentive,
                tip: tip,
                distanceKm: distanceKm,
                durationMin: durationMin,
                zone: zone,
                sourceScreenshotHash: sourceScreenshotHash,
                createdAt: createdAt,
                screenshotPath: screenshotPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrdersTable, Order>(table),
                  BaseReferences<_$AppDatabase, $OrdersTable, Order>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
      Order,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required String category,
  required double amount,
  Value<String?> rawText,
  required DateTime timestamp,
  Value<DateTime> createdAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String> category,
  Value<double> amount,
  Value<String?> rawText,
  Value<DateTime> timestamp,
  Value<DateTime> createdAt,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                category: category,
                amount: amount,
                rawText: rawText,
                timestamp: timestamp,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required double amount,
                Value<String?> rawText = const Value.absent(),
                required DateTime timestamp,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                category: category,
                amount: amount,
                rawText: rawText,
                timestamp: timestamp,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, Expense>(table),
                  BaseReferences<_$AppDatabase, $ExpensesTable, Expense>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
    >;
typedef $$EvidenceItemsTableCreateCompanionBuilder =
    EvidenceItemsCompanion Function({
      Value<int> id,
      required String type,
      required String filePath,
      required String fileHash,
      required DateTime capturedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$EvidenceItemsTableUpdateCompanionBuilder =
    EvidenceItemsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> filePath,
      Value<String> fileHash,
      Value<DateTime> capturedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$EvidenceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenceItemsTable> {
  $$EvidenceItemsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EvidenceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenceItemsTable> {
  $$EvidenceItemsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EvidenceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenceItemsTable> {
  $$EvidenceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EvidenceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidenceItemsTable,
          EvidenceItem,
          $$EvidenceItemsTableFilterComposer,
          $$EvidenceItemsTableOrderingComposer,
          $$EvidenceItemsTableAnnotationComposer,
          $$EvidenceItemsTableCreateCompanionBuilder,
          $$EvidenceItemsTableUpdateCompanionBuilder,
          (
            EvidenceItem,
            BaseReferences<_$AppDatabase, $EvidenceItemsTable, EvidenceItem>,
          ),
          EvidenceItem,
          PrefetchHooks Function()
        > {
  $$EvidenceItemsTableTableManager(_$AppDatabase db, $EvidenceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileHash = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EvidenceItemsCompanion(
                id: id,
                type: type,
                filePath: filePath,
                fileHash: fileHash,
                capturedAt: capturedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String filePath,
                required String fileHash,
                required DateTime capturedAt,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EvidenceItemsCompanion.insert(
                id: id,
                type: type,
                filePath: filePath,
                fileHash: fileHash,
                capturedAt: capturedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EvidenceItemsTable, EvidenceItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EvidenceItemsTable,
                    EvidenceItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EvidenceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidenceItemsTable,
      EvidenceItem,
      $$EvidenceItemsTableFilterComposer,
      $$EvidenceItemsTableOrderingComposer,
      $$EvidenceItemsTableAnnotationComposer,
      $$EvidenceItemsTableCreateCompanionBuilder,
      $$EvidenceItemsTableUpdateCompanionBuilder,
      (
        EvidenceItem,
        BaseReferences<_$AppDatabase, $EvidenceItemsTable, EvidenceItem>,
      ),
      EvidenceItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$EvidenceItemsTableTableManager get evidenceItems =>
      $$EvidenceItemsTableTableManager(_db, _db.evidenceItems);
}
