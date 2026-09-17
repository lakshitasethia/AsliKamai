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
}
