import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/backup/backup_controller.dart';
import '../services/backup/backup_manifest.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/relative_date.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';

/// More → Cloud backup (build_execution.md Phase 9): sign in with Google,
/// restore-or-replace on a new phone, then the backup settings.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backup = BackupController.instance;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _backup.addListener(_onChange);
  }

  @override
  void dispose() {
    _backup.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm(String title, String body, String action, {bool destructive = true}) async {
    final s = S(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(s.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              action,
              style: destructive ? const TextStyle(color: AppColors.redAlert) : null,
            ),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      await _backup.signInWithGoogle();
    } catch (e) {
      debugPrint('AsliKamai: sign-in failed: $e');
      if (mounted) _toast(S(context).signInFailed);
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _restore() async {
    final s = S(context);
    try {
      final report = await _backup.restoreAndLink();
      if (!mounted) return;
      if (report != null) {
        _toast([
          s.restoredSummary(report.restoredTotal),
          if (report.damagedFiles > 0) s.damagedFilesNote(report.damagedFiles),
        ].join(' '));
      }
    } catch (_) {
      // The problem banner explains it.
    }
  }

  Future<void> _replace() async {
    final s = S(context);
    if (!await _confirm(s.replaceCloudBackup, s.replaceCloudBackupConfirm, s.replace)) return;
    await _backup.replaceCloudAndLink();
  }

  Future<void> _toggleEnabled(bool on) async {
    final s = S(context);
    if (on) {
      await _backup.turnOn();
      return;
    }
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.turnOffBackupTitle),
        content: Text(s.turnOffBackupBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(s.keepCloudCopy)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.deleteCloudCopy, style: const TextStyle(color: AppColors.redAlert)),
          ),
        ],
      ),
    );
    if (choice == null) return;
    try {
      await _backup.turnOff(deleteCloudCopy: choice);
      if (choice && mounted) _toast(s.cloudBackupDeleted);
    } catch (_) {}
  }

  Future<void> _deleteCloudBackup() async {
    final s = S(context);
    if (!await _confirm(s.deleteCloudBackup, s.deleteCloudBackupConfirm, s.delete)) return;
    try {
      await _backup.turnOff(deleteCloudCopy: true);
      if (mounted) _toast(s.cloudBackupDeleted);
    } catch (_) {}
  }

  Future<void> _backUpNow() async {
    final report = await _backup.backupNow();
    if (report != null && mounted) _toast(S(context).backupDone);
  }

  String _problemText(Strings s, BackupProblem p) => switch (p) {
        BackupProblem.network => s.problemNetwork,
        BackupProblem.needsAppUpdate => s.problemNeedsUpdate,
        BackupProblem.damagedBackup => s.problemDamaged,
        BackupProblem.signedOut => s.problemSignedOut,
        BackupProblem.other => s.problemOther,
      };

  String _when(Strings s, DateTime dt) => formatRelativeDate(dt, s);

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.cloudBackup)),
      body: SafeArea(
        // Pushed routes sit outside RootShell's SafeArea; without this,
        // Android 15+ edge-to-edge draws the bottom under the nav bar.
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined, color: AppColors.primaryGreen),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(s.backupIntroTitle, style: AppTextStyles.sectionHeader)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(s.backupIntroBody, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text(s.backupEarningsNote, style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._body(s),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(Strings s) {
    if (!_backup.available || (!_backup.signedIn && !_backup.googleConfigured)) {
      return [Text(s.backupNotSetUp, style: AppTextStyles.bodyMuted)];
    }
    if (!_backup.signedIn) {
      return [
        ElevatedButton.icon(
          onPressed: _signingIn ? null : _signIn,
          icon: _signingIn
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.login),
          label: Text(s.signInWithGoogle),
        ),
      ];
    }
    return [
      Text(s.signedInAs(_backup.user?.email ?? ''), style: AppTextStyles.bodyMuted),
      const SizedBox(height: AppSpacing.md),
      if (_backup.problem != null) ...[
        _Banner(text: _problemText(s, _backup.problem!)),
        const SizedBox(height: AppSpacing.md),
      ],
      if (_backup.awaitingDecision) ..._decision(s) else ..._settings(s),
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton(
        onPressed: _backup.busy ? null : _backup.signOut,
        child: Text(s.signOut),
      ),
    ];
  }

  /// Signed in on a phone that isn't linked yet: restore or replace.
  List<Widget> _decision(Strings s) {
    final unreadable = _backup.cloudBackupUnreadable;
    if (unreadable != null) {
      return [
        _Banner(text: _problemText(s, unreadable)),
        if (unreadable == BackupProblem.damagedBackup) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: _replace, child: Text(s.replaceCloudBackup)),
        ],
      ];
    }
    final found = _backup.cloudBackupAwaitingDecision;
    if (found == null) {
      // Still checking, or the check failed (the banner above says why).
      return [
        if (_backup.problem == null)
          Row(children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: AppSpacing.sm),
            Text(s.checkingBackup, style: AppTextStyles.body),
          ])
        else
          OutlinedButton(onPressed: _backup.checkCloud, child: Text(s.tryAgain)),
      ];
    }
    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.foundBackupTitle, style: AppTextStyles.sectionHeader),
            const SizedBox(height: AppSpacing.xs),
            Text(_summary(s, found), style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _backup.busy ? null : _restore,
              child: _backup.busy ? Text(s.restoring) : Text(s.restoreToThisPhone),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(s.restoreHint, style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _backup.busy ? null : _replace,
              child: Text(s.replaceCloudBackup),
            ),
          ],
        ),
      ),
    ];
  }

  String _summary(Strings s, BackupManifest m) =>
      s.foundBackupSummary(_when(s, m.createdAt), m.evidence.length, m.letters.length, m.orders.length);

  List<Widget> _settings(Strings s) {
    final last = _backup.lastBackupAt;
    return [
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            SwitchListTile(
              title: Text(s.backUpAutomatically),
              subtitle: Text(s.backUpAutomaticallyHint),
              value: _backup.enabled,
              onChanged: _backup.busy ? null : _toggleEnabled,
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            SwitchListTile(
              title: Text(s.includeOrdersExpenses),
              subtitle: Text(s.includeOrdersExpensesHint),
              value: _backup.includeEarnings,
              onChanged: _backup.busy || !_backup.enabled ? null : _backup.setIncludeEarnings,
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            ListTile(
              title: Text(s.lastBackup),
              subtitle: Text(
                _backup.busy
                    ? s.backingUp
                    : last == null
                        ? s.neverBackedUp
                        : _when(s, last),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      ElevatedButton.icon(
        onPressed: _backup.busy || !_backup.enabled ? null : _backUpNow,
        icon: _backup.busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.cloud_upload_outlined),
        label: Text(_backup.busy ? s.backingUp : s.backUpNow),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextButton(
        onPressed: _backup.busy ? null : _deleteCloudBackup,
        child: Text(s.deleteCloudBackup, style: const TextStyle(color: AppColors.redAlert)),
      ),
    ];
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.charcoal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
