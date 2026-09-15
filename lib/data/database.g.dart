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
          ..write('createdAt: $createdAt')
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
          other.createdAt == this.createdAt);
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [orders];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
}
