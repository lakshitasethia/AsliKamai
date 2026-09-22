import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import '../models/rider_profile.dart';

/// "Delete everything" (build_execution.md Phase 8, per research.md's trust
/// requirements): every Order/Expense/Evidence/Letter row, the rider's saved
/// name/platforms, and every screenshot/evidence photo/letter PDF on disk.
/// Irreversible — callers must confirm with the user before calling this.
Future<void> wipeAllLocalData() async {
  await AppDatabase.instance.deleteEverything();
  await RiderProfile.clear();

  final docsDir = await getApplicationDocumentsDirectory();
  for (final dirName in ['screenshots', 'letters', 'export', 'share']) {
    final dir = Directory(p.join(docsDir.path, dirName));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
