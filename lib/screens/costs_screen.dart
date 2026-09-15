import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// Costs tab — voice-first expense entry (mockup screen 4). Phase 1 ships
/// the shell and empty state; the mic/speech-to-text flow lands in Phase 4.
class CostsScreen extends StatelessWidget {
  const CostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: EmptyState(
        icon: Icons.mic_none_rounded,
        title: 'No expenses yet',
        message: 'Tap the mic to add your first expense.',
        actionLabel: 'Add Expense',
        onAction: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice cost entry is coming in Phase 4.'),
          ),
        ),
      ),
    );
  }
}
