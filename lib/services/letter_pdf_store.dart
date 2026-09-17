import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists a generated letter's PDF bytes to local storage (Phase 7) so
/// history entries can be reopened exactly as generated, same pattern as
/// [saveScreenshot] for Orders and Evidence.
Future<String> saveLetterPdf({
  required Uint8List bytes,
  required String fileName,
}) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final lettersDir = Directory(p.join(docsDir.path, 'letters'));
  if (!await lettersDir.exists()) {
    await lettersDir.create(recursive: true);
  }
  final file = File(p.join(lettersDir.path, fileName));
  await file.writeAsBytes(bytes);
  return file.path;
}
