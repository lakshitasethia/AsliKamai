import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../models/evidence_type.dart';
import '../models/rate_cut_alert.dart';
import '../utils/currency.dart';

/// Auto-saves a detected rate cut's before/after screenshots into the
/// Evidence Locker, under Payouts — research.md's rate-cut detector
/// "saves the before and after screenshots automatically". Orders with no
/// persisted screenshot (imported before Phase 6, or hand-entered) are
/// silently skipped. Safe to call repeatedly: insertEvidenceIfNew dedups by
/// file hash, so re-detecting the same alert on every rebuild is a no-op
/// after the first save.
Future<void> saveRateCutEvidence(AppDatabase db, RateCutAlert alert) async {
  final note = 'Rate-cut evidence: ${alert.platform}, '
      '↓${alert.dropPercent.toStringAsFixed(0)}% '
      '(${formatRupees(alert.lastWeekRatePerKm)} → '
      '${formatRupees(alert.thisWeekRatePerKm)} per km)';

  for (final order in [alert.beforeOrder, ...alert.evidenceOrders]) {
    final path = order.screenshotPath;
    final hash = order.sourceScreenshotHash;
    if (path == null || hash == null) continue;

    await db.insertEvidenceIfNew(
      EvidenceItemsCompanion.insert(
        type: EvidenceType.payout.name,
        filePath: path,
        fileHash: hash,
        capturedAt: order.timestamp,
        notes: Value(note),
      ),
    );
  }
}
