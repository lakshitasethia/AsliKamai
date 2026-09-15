import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// Evidence Locker tab (mockup screen 5). Phase 1 ships the shell and empty
/// state; hashed/timestamped document storage lands in Phase 6.
class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Locker')),
      body: EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'No evidence yet',
        message: 'Add documents from your gallery.',
        actionLabel: 'Add Document',
        onAction: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evidence Locker is coming in Phase 6.'),
          ),
        ),
      ),
    );
  }
}
