import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/strings.dart';
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
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.privacyAboutAsliKamai)),
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
          Text(s.aboutIntro, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Text(s.aboutDataStaysHeader, style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.xs),
          Text(s.aboutDataStaysBody, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Text(s.aboutYouControlHeader, style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.xs),
          Text(s.aboutYouControlBody, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Text(s.aboutNotLegalHeader, style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.xs),
          Text(s.aboutNotLegalBody, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
