import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// One parsed order from a partner-app screenshot (research.md's core
/// `Order` data model, §3.8). `sourceScreenshotHash` ties the record back to
/// the screenshot it was read from, so it can later serve as evidence.
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get platform => text()(); // swiggy | zomato | blinkit | zepto | other
  TextColumn get orderRef => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get basePay => real()();
  RealColumn get incentive => real().withDefault(const Constant(0))();
  RealColumn get tip => real().withDefault(const Constant(0))();
  RealColumn get distanceKm => real().nullable()();
  IntColumn get durationMin => integer().nullable()();
  TextColumn get zone => text().nullable()();
  TextColumn get sourceScreenshotHash => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Orders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 1;

  Future<List<Order>> ordersInRange(DateTime start, DateTime end) {
    return (select(orders)
          ..where((o) => o.timestamp.isBetweenValues(start, end))
          ..orderBy([(o) => OrderingTerm.desc(o.timestamp)]))
        .get();
  }

  Future<int> insertOrder(OrdersCompanion entry) => into(orders).insert(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'asli_kamai.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
