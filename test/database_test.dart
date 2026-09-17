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

  test('deleteEvidence removes the item', () async {
    await db.insertEvidenceIfNew(evidenceEntry(hash: 'abc'));
    final saved = await db.watchAllEvidence().first;

    await db.deleteEvidence(saved.single.id);

    final all = await db.watchAllEvidence().first;
    expect(all, isEmpty);
  });
}
