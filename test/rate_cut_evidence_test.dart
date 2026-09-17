import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/models/rate_cut_alert.dart';
import 'package:asli_kamai/services/rate_cut_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order({
  required DateTime timestamp,
  String? screenshotPath,
  String? sourceScreenshotHash,
}) {
  return Order(
    id: 0,
    platform: 'swiggy',
    orderRef: null,
    timestamp: timestamp,
    basePay: 50,
    incentive: 0,
    tip: 0,
    distanceKm: 2,
    durationMin: null,
    zone: null,
    sourceScreenshotHash: sourceScreenshotHash,
    createdAt: timestamp,
    screenshotPath: screenshotPath,
  );
}

RateCutAlert _alert({required Order before, required List<Order> evidence}) {
  return RateCutAlert(
    platform: 'swiggy',
    thisWeekRatePerKm: 26,
    lastWeekRatePerKm: 45,
    beforeOrder: before,
    evidenceOrders: evidence,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() => db.close());

  test('saves the before and after orders that have a screenshot as Payout evidence', () async {
    final before = _order(
      timestamp: DateTime(2026, 9, 9),
      screenshotPath: '/tmp/before.jpg',
      sourceScreenshotHash: 'before-hash',
    );
    final after = _order(
      timestamp: DateTime(2026, 9, 16),
      screenshotPath: '/tmp/after.jpg',
      sourceScreenshotHash: 'after-hash',
    );

    await saveRateCutEvidence(db, _alert(before: before, evidence: [after]));

    final saved = await db.watchAllEvidence().first;
    expect(saved, hasLength(2));
    expect(saved.every((e) => e.type == 'payout'), isTrue);
    expect(saved.map((e) => e.fileHash), containsAll(['before-hash', 'after-hash']));
  });

  test('skips orders with no persisted screenshot', () async {
    final before = _order(timestamp: DateTime(2026, 9, 9)); // no path/hash
    final after = _order(
      timestamp: DateTime(2026, 9, 16),
      screenshotPath: '/tmp/after.jpg',
      sourceScreenshotHash: 'after-hash',
    );

    await saveRateCutEvidence(db, _alert(before: before, evidence: [after]));

    final saved = await db.watchAllEvidence().first;
    expect(saved, hasLength(1));
    expect(saved.single.fileHash, 'after-hash');
  });

  test('calling twice does not duplicate evidence', () async {
    final before = _order(
      timestamp: DateTime(2026, 9, 9),
      screenshotPath: '/tmp/before.jpg',
      sourceScreenshotHash: 'before-hash',
    );
    final alert = _alert(before: before, evidence: []);

    await saveRateCutEvidence(db, alert);
    await saveRateCutEvidence(db, alert);

    final saved = await db.watchAllEvidence().first;
    expect(saved, hasLength(1));
  });

  test('note describes the platform and drop percent', () async {
    final before = _order(
      timestamp: DateTime(2026, 9, 9),
      screenshotPath: '/tmp/before.jpg',
      sourceScreenshotHash: 'before-hash',
    );

    await saveRateCutEvidence(db, _alert(before: before, evidence: []));

    final saved = await db.watchAllEvidence().first;
    expect(saved.single.notes, contains('swiggy'));
    expect(saved.single.notes, contains('42%')); // (45-26)/45 = 42.2%
  });
}
