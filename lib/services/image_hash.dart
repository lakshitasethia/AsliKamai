import 'package:crypto/crypto.dart';

/// SHA-256 hash of screenshot bytes — a stable fingerprint used to (a) avoid
/// importing the same screenshot twice and (b) later serve as tamper-evident
/// proof in the Evidence Locker (Phase 6), per research.md §3.8.
String hashImageBytes(List<int> bytes) => sha256.convert(bytes).toString();
