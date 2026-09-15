import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/main.dart';

void main() {
  // Home and Costs both touch AppDatabase.instance. Point it at an
  // in-memory database before each test (real on-disk access goes through
  // path_provider, which has no platform implementation under flutter
  // test's host harness and hangs rather than failing fast), and close it
  // inside each test body — a top-level tearDown runs too late, after
  // flutter_test's own "no pending timers" check already ran.
  setUp(AppDatabase.resetForTest);

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

    await AppDatabase.resetForTest();
  });

  testWidgets('Tapping a nav item switches tabs', (tester) async {
    await tester.pumpWidget(const AsliKamaiApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.text('Import This Week\'s Screenshots'), findsOneWidget);

    await AppDatabase.resetForTest();
  });
}
