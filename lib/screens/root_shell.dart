import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import 'costs_screen.dart';
import 'evidence_screen.dart';
import 'home_screen.dart';
import 'import_screen.dart';
import 'more_screen.dart';

/// Bottom-nav shell hosting the app's 5 tabs. Uses IndexedStack so each
/// tab's scroll position/state is preserved when switching tabs.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ImportScreen(),
    CostsScreen(),
    EvidenceScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: s.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.file_upload_outlined),
            activeIcon: const Icon(Icons.file_upload),
            label: s.navImport,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.currency_rupee),
            label: s.navCosts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shield_outlined),
            activeIcon: const Icon(Icons.shield),
            label: s.navEvidence,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: s.navMore,
          ),
        ],
      ),
    );
  }
}
