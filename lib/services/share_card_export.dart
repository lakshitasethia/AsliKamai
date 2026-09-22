import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Renders the widget attached to [boundaryKey] (a [RepaintBoundary]) to a
/// PNG file (mockup screen 7's "Meri Asli Kamai" share card), so it can be
/// handed to the system share sheet as an image attachment.
Future<String> exportShareCardPng(GlobalKey boundaryKey) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  // 3x so the exported image looks sharp when viewed full-screen in
  // WhatsApp/Instagram, not just at the on-screen preview's resolution.
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final docsDir = await getApplicationDocumentsDirectory();
  final shareDir = Directory(p.join(docsDir.path, 'share'));
  if (!await shareDir.exists()) {
    await shareDir.create(recursive: true);
  }
  final file = File(
    p.join(shareDir.path, 'meri_asli_kamai_${DateTime.now().millisecondsSinceEpoch}.png'),
  );
  await file.writeAsBytes(bytes);
  return file.path;
}
