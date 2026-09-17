import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists a screenshot's bytes under a stable, hash-named path (Phase 6)
/// so it can later be pulled into the Evidence Locker as rate-cut proof —
/// previously the picked file was hashed and sent to Gemini but never kept.
/// Idempotent: re-saving the same hash's bytes just returns the existing
/// path without rewriting the file, matching the hash-based dedup already
/// used for orders/evidence.
Future<String> saveScreenshot({
  required List<int> bytes,
  required String hash,
}) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final screenshotsDir = Directory(p.join(docsDir.path, 'screenshots'));
  if (!await screenshotsDir.exists()) {
    await screenshotsDir.create(recursive: true);
  }
  final file = File(p.join(screenshotsDir.path, '$hash.jpg'));
  if (!await file.exists()) {
    await file.writeAsBytes(bytes);
  }
  return file.path;
}
