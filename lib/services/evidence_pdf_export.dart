import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import '../models/evidence_type.dart';

/// Builds a single PDF containing every item in [items], one per page: the
/// photo, its category, capture date, notes, and SHA-256 hash as
/// tamper-evident proof (build_execution.md Phase 6's "export selected/all
/// evidence to a single PDF").
Future<Uint8List> buildEvidencePdf(List<EvidenceItem> items) async {
  final doc = pw.Document();
  for (final item in items) {
    final bytes = await File(item.filePath).readAsBytes();
    final image = pw.MemoryImage(bytes);
    final type = EvidenceType.fromKey(item.type);

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              type.label,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Captured: ${_formatDate(item.capturedAt)}'),
            if (item.notes != null && item.notes!.isNotEmpty)
              pw.Text(sanitizeForPdf(item.notes!)),
            pw.SizedBox(height: 12),
            pw.Expanded(child: pw.Image(image, fit: pw.BoxFit.contain)),
            pw.SizedBox(height: 8),
            pw.Text(
              'SHA-256: ${item.fileHash}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
  }
  return doc.save();
}

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// The `pdf` package's default fonts only cover ASCII/Latin-1, so ₹/↓/→ in
/// notes (e.g. from [saveRateCutEvidence]'s auto-generated text) render as
/// garbled boxes instead of throwing — verified directly by exporting and
/// inspecting the PDF. Swap them for ASCII-safe equivalents before drawing.
String sanitizeForPdf(String text) {
  return text
      .replaceAll('₹', 'Rs.')
      .replaceAll('↓', '-')
      .replaceAll('→', '->')
      .replaceAll('—', '-');
}
