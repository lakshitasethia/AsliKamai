import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/l10n/app_locale.dart';
import 'package:asli_kamai/l10n/app_locale_scope.dart';
import 'package:asli_kamai/l10n/strings.dart';
import 'package:asli_kamai/main.dart';
import 'package:asli_kamai/models/parsed_order.dart';
import 'package:asli_kamai/models/platform.dart';
import 'package:asli_kamai/screens/import_review_screen.dart';
import 'package:asli_kamai/screens/root_shell.dart';

/// On-device walkthrough of every screen, in every UI language, at normal
/// and enlarged text sizes. Fails if any screen reports a Flutter error —
/// most importantly RenderFlex overflows ("yellow-and-black stripes"),
/// which unit tests on the host can't catch because they don't use the
/// real Devanagari/Kannada fonts or a real phone's screen size.
///
/// Runs against an in-memory database, so it never touches the data of an
/// install already on the phone:
///   flutter test integration_test/screen_walkthrough_test.dart -d DEVICE_ID --no-uninstall
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 1x1 transparent PNG, standing in for a saved screenshot/notice photo.
  final pngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  );

  Future<void> seed() async {
    await AppDatabase.resetForTest();
    final db = AppDatabase.instance;
    final dir = await getTemporaryDirectory();
    final img = File('${dir.path}/walkthrough.png')..writeAsBytesSync(pngBytes);

    final now = DateTime.now();
    // Last week at ₹20/km, this week at ~₹13/km on Swiggy → a 30% rate cut,
    // so Home shows the alert card and its details screen is reachable.
    for (var i = 0; i < 6; i++) {
      await db.insertOrder(
        OrdersCompanion.insert(
          platform: 'swiggy',
          orderRef: Value('LW$i'),
          timestamp: now.subtract(Duration(days: 7, hours: i)),
          basePay: 80,
          distanceKm: const Value(4),
          durationMin: const Value(25),
          zone: const Value('Koramangala 5th Block'),
        ),
      );
      await db.insertOrder(
        OrdersCompanion.insert(
          platform: i.isEven ? 'swiggy' : 'zomato',
          orderRef: Value('TW$i'),
          timestamp: now.subtract(Duration(hours: i)),
          basePay: 28,
          incentive: const Value(15),
          tip: const Value(10),
          distanceKm: const Value(4),
          durationMin: const Value(30),
          zone: const Value('HSR Layout Sector 2'),
          screenshotPath: Value(img.path),
        ),
      );
    }
    await db.insertExpense(
      ExpensesCompanion.insert(
        category: 'fuel',
        amount: 300,
        rawText: const Value('petrol 300'),
        timestamp: now,
      ),
    );
    await db.insertEvidenceIfNew(
      EvidenceItemsCompanion.insert(
        type: 'notice',
        filePath: img.path,
        fileHash: 'walkthrough-notice',
        capturedAt: now,
        notes: const Value('ID blocked without reason'),
      ),
    );
    await db.insertLetter(
      LettersCompanion.insert(
        templateId: 'idBlockReasons',
        lang: 'kannada',
        filePath: '${dir.path}/missing.pdf',
        generatedAt: now,
      ),
    );
  }

  testWidgets('every screen renders without errors in every language', (
    tester,
  ) async {
    await dotenv.load(fileName: '.env');
    await initCloud();
    await seed();
    final originalLocale = await AppLocale.load();

    final errors = <String>[];
    var where = 'startup';
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final summary = details.exceptionAsString().split('\n').first;
      errors.add('[$where] $summary');
      debugPrint('WALKTHROUGH ERROR [$where] $summary');
    };

    try {
      await tester.pumpWidget(const AsliKamaiApp());
      await tester.pumpAndSettle();

      // pumpAndSettle times out on screens with an endless spinner; a fixed
      // pump sequence is enough for streams and layout to land.
      Future<void> settle() async {
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      Future<void> scrollThrough() async {
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isEmpty) return;
        for (var i = 0; i < 4; i++) {
          await tester.drag(
            scrollables.first,
            const Offset(0, -400),
            warnIfMissed: false,
          );
          await settle();
        }
      }

      Future<void> back() async {
        await tester.pageBack();
        await settle();
      }

      Future<void> visit(String name, Future<void> Function() open) async {
        where = name;
        debugPrint('WALKTHROUGH STEP $where');
        await open();
        await settle();
        await scrollThrough();
        await back();
      }

      Strings strings() => S(tester.element(find.byType(RootShell)));

      Future<void> tab(String label) async {
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavigationBar),
            matching: find.text(label),
          ),
        );
        await settle();
      }

      Future<void> tapIcon(IconData icon) async {
        final f = find.byIcon(icon).first;
        await tester.ensureVisible(f);
        await tester.pump();
        await tester.tap(f);
      }

      for (final textScale in [1.0, 1.3]) {
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        for (final locale in AppLocale.values) {
          final label = '${locale.name} @${textScale}x';
          await AppLocaleScope.of(tester.element(find.byType(RootShell)))
              .setLocale(locale);
          await settle();
          final s = strings();

          where = '$label Home';

          debugPrint('WALKTHROUGH STEP $where');
          await tab(s.navHome);
          await scrollThrough();
          await visit('$label Rate-cut details', () async {
            final details = find.text(s.viewFullDetails);
            await tester.ensureVisible(details);
            await tester.pump();
            await tester.tap(details);
          });
          await visit(
            '$label Settings (from Home)',
            () => tapIcon(Icons.settings_outlined),
          );

          where = '$label Import';

          debugPrint('WALKTHROUGH STEP $where');
          await tab(s.navImport);
          await scrollThrough();
          await visit('$label Import review', () async {
            final ctx = tester.element(find.byType(RootShell));
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => ImportReviewScreen(
                  parsedOrders: [
                    ParsedOrder(
                      platform: GigPlatform.swiggy,
                      orderRef: '#98765',
                      timestamp: DateTime.now(),
                      basePay: 42,
                      incentive: 10,
                      distanceKm: 3.4,
                      durationMin: 22,
                      zone: 'Indiranagar 100ft Road',
                    ),
                    ParsedOrder(
                      platform: GigPlatform.other,
                      timestamp: DateTime.now(),
                      basePay: 0,
                      parseFailed: true,
                    ),
                  ],
                ),
              ),
            );
          });

          where = '$label Costs';

          debugPrint('WALKTHROUGH STEP $where');
          await tab(s.navCosts);
          await scrollThrough();

          where = '$label Evidence';

          debugPrint('WALKTHROUGH STEP $where');
          await tab(s.navEvidence);
          await scrollThrough();
          await visit('$label Evidence detail', () async {
            final tile = find.byType(Image).first;
            await tester.ensureVisible(tile);
            await tester.pump();
            await tester.tap(tile);
          });

          where = '$label More';

          debugPrint('WALKTHROUGH STEP $where');
          await tab(s.navMore);
          await scrollThrough();
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 2000),
          );
          await settle();
          await visit('$label Profile', () => tapIcon(Icons.person_outline));
          await visit('$label Share card', () => tapIcon(Icons.share_outlined));
          await visit('$label About', () => tapIcon(Icons.info_outline));
          await visit('$label Cloud backup', () => tapIcon(Icons.cloud_outlined));

          where = '$label Language picker';

          debugPrint('WALKTHROUGH STEP $where');
          await tapIcon(Icons.language_outlined);
          await settle();
          await tester.tapAt(const Offset(20, 20)); // dismiss the sheet
          await settle();

          where = '$label Letter generator';

          debugPrint('WALKTHROUGH STEP $where');
          await tapIcon(Icons.description_outlined);
          await settle();
          await scrollThrough();
          final templateCount = find.byType(ListTile).evaluate().length;
          for (var i = 0; i < 3 && i < templateCount; i++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, 2000),
            );
            await settle();
            await visit('$label Letter form #$i', () async {
              final tiles = find.byWidgetPredicate(
                (w) => w is ListTile && w.isThreeLine == true,
              );
              await tester.tap(tiles.at(i));
            });
          }
          await back();
        }
      }
    } finally {
      FlutterError.onError = originalOnError;
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await AppLocale.save(originalLocale);
    }

    expect(errors, isEmpty, reason: errors.toSet().join('\n'));
  });
}
