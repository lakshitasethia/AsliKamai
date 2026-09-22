import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
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

  /// Local file path of the source screenshot, persisted at import time
  /// (Phase 6) so it can later be pulled into the Evidence Locker as
  /// rate-cut proof. Null for orders imported before Phase 6, or entered
  /// by hand.
  TextColumn get screenshotPath => text().nullable()();
}

/// A saved document (research.md's core `Evidence` data model, §3.8): a
/// block/suspension notice, support ticket, or payout statement, kept with
/// a SHA-256 hash as tamper-evident proof it hasn't changed since capture.
class EvidenceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // notice | ticket | payout
  TextColumn get filePath => text()();
  TextColumn get fileHash => text()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// A generated letter (research.md's core `Letter` data model, §3.8). The
/// rendered PDF is persisted (like Evidence's photos) so a past letter can
/// be reopened exactly as it was generated, even if the Order/Evidence it
/// referenced is later edited or deleted.
class Letters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get templateId => text()(); // deductionExplanation | idBlockReasons | grievanceFiling
  TextColumn get lang => text()(); // english | hindi | kannada
  TextColumn get filePath => text()();
  DateTimeColumn get generatedAt => dateTime()();
}

/// A logged cost (research.md's core `Expense` data model, §3.8), typically
/// added by voice ("petrol 300") on the Costs tab. Feeds the Dashboard's
/// gross-minus-costs net figure.
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // fuel | food | mobile | repair | toll | parking | other
  RealColumn get amount => real()();
  TextColumn get rawText => text().nullable()(); // what was heard/typed, for correction context
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Orders, Expenses, EvidenceItems, Letters])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test-only: an in-memory database, bypassing path_provider (which has
  /// no platform implementation under `flutter test`'s host harness —
  /// awaiting it there hangs rather than throwing).
  @visibleForTesting
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  /// Test-only: points [instance] at an in-memory database instead of the
  /// real on-disk one, so widget tests that touch [instance] don't hang on
  /// path_provider and don't leak state across tests.
  @visibleForTesting
  static Future<void> resetForTest() async {
    await _instance?.close();
    _instance = AppDatabase.forTesting();
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(expenses);
          }
          if (from < 3) {
            await m.addColumn(orders, orders.screenshotPath);
            await m.createTable(evidenceItems);
          }
          if (from < 4) {
            await m.createTable(letters);
          }
        },
      );

  Future<List<Order>> ordersInRange(DateTime start, DateTime end) {
    return (select(orders)
          ..where((o) => o.timestamp.isBetweenValues(start, end))
          ..orderBy([(o) => OrderingTerm.desc(o.timestamp)]))
        .get();
  }

  Future<int> insertOrder(OrdersCompanion entry) => into(orders).insert(entry);

  /// Inserts [entry] unless its `sourceScreenshotHash` already exists on
  /// another order — re-importing the same screenshot (e.g. picking it
  /// twice from the gallery) would otherwise silently double-count that
  /// order's pay. Entries with no hash (e.g. hand-edited orders) always
  /// insert. Returns whether it actually inserted.
  Future<bool> insertOrderIfNew(OrdersCompanion entry) async {
    final hash = entry.sourceScreenshotHash.present
        ? entry.sourceScreenshotHash.value
        : null;
    if (hash != null) {
      final existing = await (select(orders)
            ..where((o) => o.sourceScreenshotHash.equals(hash)))
          .getSingleOrNull();
      if (existing != null) return false;
    }
    await into(orders).insert(entry);
    return true;
  }

  /// Most recent orders regardless of week, for the Letter Generator's
  /// "reference an order" picker (Phase 7) — unlike [ordersInRange], not
  /// scoped to any particular week.
  Future<List<Order>> recentOrders({int limit = 30}) {
    return (select(orders)
          ..orderBy([(o) => OrderingTerm.desc(o.timestamp)])
          ..limit(limit))
        .get();
  }

  Stream<List<Order>> watchOrdersInRange(DateTime start, DateTime end) {
    return (select(orders)
          ..where((o) => o.timestamp.isBetweenValues(start, end))
          ..orderBy([(o) => OrderingTerm.desc(o.timestamp)]))
        .watch();
  }

  Future<List<Expense>> expensesInRange(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((e) => e.timestamp.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)]))
        .get();
  }

  Stream<List<Expense>> watchRecentExpenses({int limit = 3}) {
    return (select(expenses)
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)])
          ..limit(limit))
        .watch();
  }

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<void> updateExpense(int id, ExpensesCompanion entry) =>
      (update(expenses)..where((e) => e.id.equals(id))).write(entry);

  Future<void> deleteExpense(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

  /// Inserts [entry] unless its `fileHash` already exists on another
  /// evidence item — same dedup reasoning as [insertOrderIfNew]: adding the
  /// same photo twice (by hand, or via the rate-cut auto-save) shouldn't
  /// create a second copy. Returns whether it actually inserted.
  Future<bool> insertEvidenceIfNew(EvidenceItemsCompanion entry) async {
    final existing = await (select(evidenceItems)
          ..where((e) => e.fileHash.equals(entry.fileHash.value)))
        .getSingleOrNull();
    if (existing != null) return false;
    await into(evidenceItems).insert(entry);
    return true;
  }

  Stream<List<EvidenceItem>> watchAllEvidence() {
    return (select(evidenceItems)
          ..orderBy([(e) => OrderingTerm.desc(e.capturedAt)]))
        .watch();
  }

  Future<void> deleteEvidence(int id) =>
      (delete(evidenceItems)..where((e) => e.id.equals(id))).go();

  Future<int> insertLetter(LettersCompanion entry) => into(letters).insert(entry);

  Stream<List<Letter>> watchAllLetters() {
    return (select(letters)
          ..orderBy([(l) => OrderingTerm.desc(l.generatedAt)]))
        .watch();
  }

  Future<void> deleteLetter(int id) =>
      (delete(letters)..where((l) => l.id.equals(id))).go();

  // "Export everything" (Phase 8): every row, unfiltered by week/type.
  Future<List<Order>> allOrders() => select(orders).get();
  Future<List<Expense>> allExpenses() => select(expenses).get();
  Future<List<EvidenceItem>> allEvidence() => select(evidenceItems).get();
  Future<List<Letter>> allLetters() => select(letters).get();

  /// "Delete everything" (Phase 8): wipes every table. Caller is
  /// responsible for also clearing [RiderProfile] and the on-disk
  /// screenshots/letters directories — this only covers the database.
  Future<void> deleteEverything() {
    return batch((b) {
      b.deleteAll(orders);
      b.deleteAll(expenses);
      b.deleteAll(evidenceItems);
      b.deleteAll(letters);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'asli_kamai.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
