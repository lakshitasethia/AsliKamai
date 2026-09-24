import 'package:asli_kamai/data/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() => db.close());

  OrdersCompanion entry({String? hash, String orderRef = 'X'}) {
    return OrdersCompanion.insert(
      platform: 'swiggy',
      orderRef: Value(orderRef),
      timestamp: DateTime(2026, 9, 16),
      basePay: 50,
      sourceScreenshotHash: Value(hash),
    );
  }

  test('insertOrderIfNew inserts a new order and returns true', () async {
    final inserted = await db.insertOrderIfNew(entry(hash: 'abc'));

    expect(inserted, isTrue);
    final all =
        await db.ordersInRange(DateTime(2026), DateTime(2027));
    expect(all, hasLength(1));
  });

  test('insertOrderIfNew skips a duplicate sourceScreenshotHash and returns false', () async {
    await db.insertOrderIfNew(entry(hash: 'abc', orderRef: 'X'));
    final insertedAgain =
        await db.insertOrderIfNew(entry(hash: 'abc', orderRef: 'Y'));

    expect(insertedAgain, isFalse);
    final all =
        await db.ordersInRange(DateTime(2026), DateTime(2027));
    expect(all, hasLength(1));
    expect(all.single.orderRef, 'X'); // the first insert wins
  });

  test('insertOrderIfNew always inserts orders with no sourceScreenshotHash', () async {
    await db.insertOrderIfNew(entry(hash: null));
    await db.insertOrderIfNew(entry(hash: null));

    final all =
        await db.ordersInRange(DateTime(2026), DateTime(2027));
    expect(all, hasLength(2));
  });

  EvidenceItemsCompanion evidenceEntry({required String hash, String type = 'notice'}) {
    return EvidenceItemsCompanion.insert(
      type: type,
      filePath: '/tmp/$hash.jpg',
      fileHash: hash,
      capturedAt: DateTime(2026, 9, 16),
    );
  }

  test('insertEvidenceIfNew inserts a new item and returns true', () async {
    final inserted = await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc'));

    expect(inserted, isTrue);
    final all = await db.watchAllEvidence().first;
    expect(all, hasLength(1));
  });

  test('insertEvidenceIfNew skips a duplicate fileHash and returns false', () async {
    await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc', type: 'notice'));
    final insertedAgain =
        await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc', type: 'ticket'));

    expect(insertedAgain, isFalse);
    final all = await db.watchAllEvidence().first;
    expect(all, hasLength(1));
    expect(all.single.type, 'notice'); // the first insert wins
  });

  test('insertEvidenceIfNew copes with duplicates saved by older versions', () async {
    // Before the race fix, two copies of one photo could be saved; restoring
    // a backup onto such a phone must not crash.
    await db.into(db.evidenceItems).insert(evidenceEntry(hash: 'abc'));
    await db.into(db.evidenceItems).insert(evidenceEntry(hash: 'abc'));

    expect(await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc')), isFalse);
    expect(await db.watchAllEvidence().first, hasLength(2));
  });

  test('watchAllEvidence orders by capturedAt, most recent first', () async {
    await db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
      type: 'notice',
      filePath: '/tmp/old.jpg',
      fileHash: 'old',
      capturedAt: DateTime(2026, 9, 1),
    ));
    await db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
      type: 'ticket',
      filePath: '/tmp/new.jpg',
      fileHash: 'new',
      capturedAt: DateTime(2026, 9, 16),
    ));

    final all = await db.watchAllEvidence().first;
    expect(all.map((e) => e.fileHash), ['new', 'old']);
  });

  test('setEvidenceDocumentDate stores the date read off the document', () async {
    await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc', type: 'notice'));
    final saved = (await db.watchAllEvidence().first).single;
    expect(saved.documentDate, isNull);

    await db.setEvidenceDocumentDate(saved.id, DateTime(2026, 9, 20));

    final updated = (await db.watchAllEvidence().first).single;
    expect(updated.documentDate, DateTime(2026, 9, 20));
    expect(updated.capturedAt, saved.capturedAt);
  });

  test('deleteEvidence removes the item', () async {
    await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc'));
    final saved = await db.watchAllEvidence().first;

    await db.deleteEvidence(saved.single.id);

    final all = await db.watchAllEvidence().first;
    expect(all, isEmpty);
  });

  LettersCompanion letterEntry({String templateId = 'deductionExplanation'}) {
    return LettersCompanion.insert(
      templateId: templateId,
      lang: 'english',
      filePath: '/tmp/letter.pdf',
      generatedAt: DateTime(2026, 9, 16),
    );
  }

  test('insertLetter saves a new letter', () async {
    await db.insertLetter(letterEntry());

    final all = await db.watchAllLetters().first;
    expect(all, hasLength(1));
    expect(all.single.templateId, 'deductionExplanation');
  });

  test('watchAllLetters orders by generatedAt, most recent first', () async {
    await db.insertLetter(LettersCompanion.insert(
      templateId: 'deductionExplanation',
      lang: 'english',
      filePath: '/tmp/old.pdf',
      generatedAt: DateTime(2026, 9, 1),
    ));
    await db.insertLetter(LettersCompanion.insert(
      templateId: 'idBlockReasons',
      lang: 'hindi',
      filePath: '/tmp/new.pdf',
      generatedAt: DateTime(2026, 9, 16),
    ));

    final all = await db.watchAllLetters().first;
    expect(all.map((l) => l.templateId), ['idBlockReasons', 'deductionExplanation']);
  });

  test('deleteLetter removes the letter', () async {
    await db.insertLetter(letterEntry());
    final saved = await db.watchAllLetters().first;

    await db.deleteLetter(saved.single.id);

    final all = await db.watchAllLetters().first;
    expect(all, isEmpty);
  });

  test('allOrders/allExpenses/allEvidence/allLetters return every row unfiltered', () async {
    await db.insertOrderIfNew(entry(hash: 'abc'));
    await db.insertExpense(ExpensesCompanion.insert(
      category: 'fuel',
      amount: 100,
      timestamp: DateTime(2026, 9, 16),
    ));
    await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc'));
    await db.insertLetter(letterEntry());

    expect(await db.allOrders(), hasLength(1));
    expect(await db.allExpenses(), hasLength(1));
    expect(await db.allEvidence(), hasLength(1));
    expect(await db.allLetters(), hasLength(1));
  });

  test('deleteEverything empties every table', () async {
    await db.insertOrderIfNew(entry(hash: 'abc'));
    await db.insertExpense(ExpensesCompanion.insert(
      category: 'fuel',
      amount: 100,
      timestamp: DateTime(2026, 9, 16),
    ));
    await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc'));
    await db.insertLetter(letterEntry());

    await db.deleteEverything();

    expect(await db.allOrders(), isEmpty);
    expect(await db.allExpenses(), isEmpty);
    expect(await db.allEvidence(), isEmpty);
    expect(await db.allLetters(), isEmpty);
  });
}
