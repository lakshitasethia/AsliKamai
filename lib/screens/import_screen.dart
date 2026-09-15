import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// Weekly Screenshot Import tab (mockup screen 1). Phase 1 ships the shell
/// and empty state; the gallery picker + OCR review flow lands in Phase 2.
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import This Week\'s Screenshots')),
      body: EmptyState(
        icon: Icons.photo_library_outlined,
        title: 'No screenshots yet',
        message: 'Tap to pick from gallery.',
        actionLabel: 'Pick Screenshots',
        onAction: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screenshot import is coming in Phase 2.'),
          ),
        ),
      ),
    );
  }
}
