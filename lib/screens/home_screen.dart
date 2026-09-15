import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';

/// Weekly Dashboard tab (mockup screen 3). Phase 1 ships the shell and empty
/// state only — the real net-earnings/₹-per-hour cards land in Phase 3 once
/// order data exists to summarize.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _AppTitle(),
        actions: const [
          _OfflinePill(),
          SizedBox(width: 4),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings_outlined, color: AppColors.charcoal),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'No data yet',
        message: 'Import screenshots to see your weekly summary.',
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('AsliKamai', style: Theme.of(context).textTheme.titleLarge),
        Text(
          'असली कमाई',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.mutedGrey),
        ),
      ],
    );
  }
}

class _OfflinePill extends StatelessWidget {
  const _OfflinePill();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.mutedGrey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Offline',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.mutedGrey),
        ),
      ],
    );
  }
}
