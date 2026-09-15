import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

/// More tab: profile, language, and the features reached from here in later
/// phases (Letter Generator, Share Card, data export/delete). Not from the
/// mockup directly — the mockup didn't spec this screen — so it's built to
/// house those entry points sensibly as they land.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SectionHeader('Tools'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MoreTile(
                  icon: Icons.description_outlined,
                  title: 'Letter Generator',
                  subtitle: 'Coming in Phase 7',
                  onTap: () => _comingSoon(context, 'Letter Generator'),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.share_outlined,
                  title: 'Share Card',
                  subtitle: 'Coming in Phase 8',
                  onTap: () => _comingSoon(context, 'Share Card'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader('Your data'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MoreTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English (Hindi, Kannada coming in Phase 8)',
                  onTap: () => _comingSoon(context, 'Language selection'),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.download_outlined,
                  title: 'Export everything',
                  onTap: () => _comingSoon(context, 'Data export'),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.delete_outline,
                  title: 'Delete everything',
                  iconColor: AppColors.redAlert,
                  onTap: () => _comingSoon(context, 'Delete everything'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader('About'),
          AppCard(
            padding: EdgeInsets.zero,
            child: _MoreTile(
              icon: Icons.info_outline,
              title: 'Privacy & about AsliKamai',
              onTap: () => _comingSoon(context, 'About'),
            ),
          ),
        ],
      ),
    );
  }

  static void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature is not built yet.')));
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.charcoal),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
      onTap: onTap,
    );
  }
}
