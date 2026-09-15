import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asli_kamai/main.dart';

void main() {
  testWidgets('App boots to the Home tab with all 5 nav destinations',
      (tester) async {
    await tester.pumpWidget(const AsliKamaiApp());
    await tester.pumpAndSettle();

    expect(find.text('AsliKamai'), findsWidgets);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Costs'), findsOneWidget);
    expect(find.text('Evidence'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('Tapping a nav item switches tabs', (tester) async {
    await tester.pumpWidget(const AsliKamaiApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.text('Import This Week\'s Screenshots'), findsOneWidget);
  });
}
