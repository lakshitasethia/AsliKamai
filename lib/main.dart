import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_locale_scope.dart';
import 'screens/root_shell.dart';
import 'services/backup/backup_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initCloud();
  runApp(const AsliKamaiApp());
}

/// Supabase (optional cloud backup, Phase 9). A build without Supabase
/// config simply has no backup — everything else works offline as before.
Future<void> initCloud() async {
  final url = dotenv.maybeGet('SUPABASE_URL') ?? '';
  final key = dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY') ?? '';
  if (url.isNotEmpty && key.isNotEmpty) {
    try {
      await Supabase.initialize(url: url, publishableKey: key);
    } catch (e) {
      debugPrint('AsliKamai: Supabase init failed, backup disabled: $e');
    }
  }
  await BackupController.instance.init();
}

class AsliKamaiApp extends StatelessWidget {
  const AsliKamaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      child: MaterialApp(
        title: 'AsliKamai',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootShell(),
      ),
    );
  }
}
