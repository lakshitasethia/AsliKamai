import 'package:flutter/material.dart';

import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AsliKamaiApp());
}

class AsliKamaiApp extends StatelessWidget {
  const AsliKamaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsliKamai',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}
