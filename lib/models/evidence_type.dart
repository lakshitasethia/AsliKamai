import 'package:flutter/material.dart';

/// Evidence Locker categories (mockup screen 5's tabs, research.md §3.8's
/// `Evidence.type`): block/suspension notices, support tickets, payout
/// statements.
enum EvidenceType {
  notice,
  ticket,
  payout;

  static EvidenceType fromKey(String key) {
    return EvidenceType.values.firstWhere(
      (t) => t.name == key.toLowerCase().trim(),
      orElse: () => EvidenceType.notice,
    );
  }

  String get label => switch (this) {
        EvidenceType.notice => 'Notices',
        EvidenceType.ticket => 'Tickets',
        EvidenceType.payout => 'Payouts',
      };

  IconData get icon => switch (this) {
        EvidenceType.notice => Icons.warning_amber_rounded,
        EvidenceType.ticket => Icons.confirmation_number_outlined,
        EvidenceType.payout => Icons.receipt_long_outlined,
      };
}
