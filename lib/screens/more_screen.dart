import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/data_export.dart';
import '../services/wipe_local_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/section_header.dart';
import 'about_screen.dart';
import 'letter_generator_screen.dart';
import 'settings_screen.dart';
import 'share_card_screen.dart';

/// More tab: profile, language, and the features reached from here in later
/// phases (Letter Generator, Share Card, data export/delete). Not from the
/// mockup directly — the mockup didn't spec this screen — so it's built to
/// house those entry points sensibly as they land.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _exporting = false;
  bool _deleting = false;

  Future<void> _exportEverything() async {
    setState(() => _exporting = true);
    try {
      final path = await exportAllDataAsJson();
      if (!mounted) return;
      await Share.shareXFiles([XFile(path)], text: 'AsliKamai data export');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _deleteEverything() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'This permanently deletes every order, expense, evidence photo, '
          'and letter, plus your saved name and platforms. This cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete everything', style: TextStyle(color: AppColors.redAlert)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await wipeAllLocalData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Everything has been deleted.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SectionHeader('Profile'),
          AppCard(
            padding: EdgeInsets.zero,
            child: _MoreTile(
              icon: Icons.person_outline,
              title: 'Your name & platforms',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader('Tools'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MoreTile(
                  icon: Icons.description_outlined,
                  title: 'Letter Generator',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LetterGeneratorScreen()),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.share_outlined,
                  title: 'Share Card',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ShareCardScreen()),
                  ),
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
                  subtitle: _exporting ? 'Preparing export…' : null,
                  onTap: _exporting ? null : _exportEverything,
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.delete_outline,
                  title: 'Delete everything',
                  subtitle: _deleting ? 'Deleting…' : null,
                  iconColor: AppColors.redAlert,
                  onTap: _deleting ? null : _deleteEverything,
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
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: onTap == null ? AppColors.mutedGrey : (iconColor ?? AppColors.charcoal)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
      onTap: onTap,
    );
  }
}
