import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../services/backup/backup_controller.dart';
import '../services/data_export.dart';
import '../services/wipe_local_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/section_header.dart';
import 'about_screen.dart';
import 'backup_screen.dart';
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
    final s = S(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteEverythingConfirmTitle),
        content: Text(s.deleteEverythingConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.deleteEverything, style: const TextStyle(color: AppColors.redAlert)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final backup = BackupController.instance;
      if (backup.signedIn) {
        try {
          await backup.deleteAccount();
        } catch (e) {
          debugPrint('AsliKamai: cloud delete failed: $e');
          if (!mounted) return;
          final phoneOnly = await _askDeletePhoneOnly();
          if (!phoneOnly || !mounted) return;
          // Stop syncing first, so the wiped phone can't be auto-backed-up
          // as an empty backup over the cloud copy the rider is keeping.
          await backup.detachFromCloud();
        }
      }
      await wipeAllLocalData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S(context).everythingDeletedToast)),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<bool> _askDeletePhoneOnly() async {
    final s = S(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.cloudDeleteFailedTitle),
        content: Text(s.cloudDeleteFailedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.deleteFromPhoneOnly, style: const TextStyle(color: AppColors.redAlert)),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _pickLanguage() async {
    final controller = AppLocaleScope.of(context);
    final picked = await showModalBottomSheet<AppLocale>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LanguagePickerSheet(current: controller.locale),
    );
    if (picked != null) await controller.setLocale(picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final currentLocale = AppLocaleScope.of(context).locale;
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.navMore)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          SectionHeader(s.profile),
          AppCard(
            padding: EdgeInsets.zero,
            child: _MoreTile(
              icon: Icons.person_outline,
              title: s.yourNamePlatforms,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(s.tools),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MoreTile(
                  icon: Icons.description_outlined,
                  title: s.letterGeneratorTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LetterGeneratorScreen()),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.share_outlined,
                  title: s.shareCard,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ShareCardScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(s.yourData),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: BackupController.instance,
                  builder: (context, _) {
                    final backup = BackupController.instance;
                    return _MoreTile(
                      icon: Icons.cloud_outlined,
                      title: s.cloudBackup,
                      subtitle: backup.signedIn && backup.enabled && backup.linked
                          ? s.backupOn
                          : s.backupOff,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BackupScreen()),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.language_outlined,
                  title: s.languageTile,
                  subtitle: currentLocale.label,
                  onTap: _pickLanguage,
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.download_outlined,
                  title: s.exportEverything,
                  subtitle: _exporting ? s.preparingExport : null,
                  onTap: _exporting ? null : _exportEverything,
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _MoreTile(
                  icon: Icons.delete_outline,
                  title: s.deleteEverything,
                  subtitle: _deleting ? s.deletingEllipsis : null,
                  iconColor: AppColors.redAlert,
                  onTap: _deleting ? null : _deleteEverything,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(s.about),
          AppCard(
            padding: EdgeInsets.zero,
            child: _MoreTile(
              icon: Icons.info_outline,
              title: s.privacyAboutAsliKamai,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.current});

  final AppLocale current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S(context).languageTile, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            for (final locale in AppLocale.values)
              ListTile(
                title: Text(locale.label),
                trailing: locale == current
                    ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                    : null,
                onTap: () => Navigator.of(context).pop(locale),
              ),
          ],
        ),
      ),
    );
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
