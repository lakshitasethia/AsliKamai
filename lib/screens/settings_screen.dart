import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/platform.dart';
import '../models/rider_profile.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/screen_title.dart';

/// Profile settings (build_execution.md Phase 8): name and the platform(s)
/// a rider works. Name already existed as a Phase 7 pull-forward (letters
/// need it); this screen is the first place it's actually editable outside
/// the letter form, plus the new platforms field.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  Set<GigPlatform> _platforms = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await RiderProfile.load();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile.name;
      _platforms = profile.platforms.toSet();
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await RiderProfile.saveName(_nameController.text.trim());
    await RiderProfile.savePlatforms(_platforms.toList());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S(context).savedToast)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.profile)),
      body: _loading
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.yourName),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(s.platformsYouWork, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final platform in GigPlatform.values)
                      if (platform != GigPlatform.other)
                        FilterChip(
                          label: Text(platform.label),
                          avatar: Icon(platform.icon, size: 18, color: platform.color),
                          selected: _platforms.contains(platform),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _platforms.add(platform);
                            } else {
                              _platforms.remove(platform);
                            }
                          }),
                        ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(s.save),
                ),
              ],
            ),
    );
  }
}
