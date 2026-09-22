import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';

/// Builds a single JSON file of every row in every table (build_execution.md
/// Phase 8's "data export" option, per research.md's trust requirements) so
/// a rider can keep their own copy or move it elsewhere. Evidence/letter
/// entries carry their `filePath` but not the file bytes themselves — this
/// is a data export, not a full backup archive.
Future<String> exportAllDataAsJson() async {
  final db = AppDatabase.instance;
  final orders = await db.allOrders();
  final expenses = await db.allExpenses();
  final evidence = await db.allEvidence();
  final letters = await db.allLetters();

  final json = {
    'exportedAt': DateTime.now().toIso8601String(),
    'orders': orders.map((o) => o.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'evidence': evidence.map((e) => e.toJson()).toList(),
    'letters': letters.map((l) => l.toJson()).toList(),
  };

  final docsDir = await getApplicationDocumentsDirectory();
  final exportDir = Directory(p.join(docsDir.path, 'export'));
  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }
  final file = File(
    p.join(exportDir.path, 'asli_kamai_export_${DateTime.now().millisecondsSinceEpoch}.json'),
  );
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  return file.path;
}
