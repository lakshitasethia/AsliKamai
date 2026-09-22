import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/screen_title.dart';

/// Static privacy/about page (build_execution.md Phase 8), summarizing the
/// local-first/trust stance from research.md §3.8-3.10: orders, expenses
/// and evidence never leave the phone unless the rider explicitly shares or
/// exports them; there is no cloud sync in this build (deferred to Phase 9,
/// opt-in even then).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Privacy & about')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('AsliKamai', style: AppTextStyles.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data;
              return Text(
                version == null
                    ? ' '
                    : 'Version ${version.version} (${version.buildNumber})',
                style: AppTextStyles.bodyMuted,
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'AsliKamai helps Karnataka\'s delivery and ride-hailing gig '
            'workers see their real net earnings, catch pay-rate cuts, and '
            'build evidence for disputes under the Karnataka Platform-Based '
            'Gig Workers Act.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Your data stays on your phone', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Orders, expenses, evidence photos and letters are stored only '
            'in this app\'s local database — never sent anywhere except '
            'when a screenshot is read by the vision AI to extract order '
            'details, or when you explicitly export, share, or generate a '
            'letter. There is no account and no cloud sync in this build.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('You control it', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Export everything (More → Export everything) at any time as a '
            'file you can keep or move elsewhere. Delete everything (More → '
            'Delete everything) permanently erases all of it from this '
            'phone.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Not legal advice', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The Letter Generator drafts information requests citing the '
            'Act — it is not a substitute for advice from a labour lawyer '
            'or union, and its templates are pending their review.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
