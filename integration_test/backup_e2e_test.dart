import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/l10n/app_locale.dart';
import 'package:asli_kamai/l10n/app_locale_scope.dart';
import 'package:asli_kamai/main.dart';
import 'package:asli_kamai/models/platform.dart';
import 'package:asli_kamai/models/rider_profile.dart';
import 'package:asli_kamai/screens/backup_screen.dart';
import 'package:asli_kamai/screens/root_shell.dart';
import 'package:asli_kamai/services/backup/backup_controller.dart';
import 'package:asli_kamai/services/backup/backup_manifest.dart';
import 'package:asli_kamai/services/backup/backup_remote.dart';
import 'package:asli_kamai/services/backup/backup_service.dart';
import 'package:asli_kamai/services/image_hash.dart';
import 'package:asli_kamai/services/letter_pdf_store.dart';
import 'package:asli_kamai/services/screenshot_store.dart';
import 'package:asli_kamai/services/wipe_local_data.dart';

/// Live end-to-end test of cloud backup against the real Supabase project:
/// real auth, real Storage + its per-rider access rules, the real
/// delete-account Edge Function. Google sign-in can't be automated, so it
/// signs in two throwaway email accounts (created server-side; the app has
/// no email sign-up). Run on an emulator — it wipes the app's local data:
///
///   flutter test integration_test/backup_e2e_test.dart -d emulator-5554 \
///     --no-uninstall --dart-define=E2E_PASSWORD=...
///
/// The test deletes both accounts at the end via delete-account.
const _password = String.fromEnvironment('E2E_PASSWORD');
const _emailA = 'e2e-rider-a@aslikamai.test';
const _emailB = 'e2e-rider-b@aslikamai.test';

// Real 1x1 PNGs (red/green/blue): the Evidence tab decodes them.
final _noticeImg = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 56, 33, 39, 7, 0, 2, 182, 1, 5, 52, 166, 117, 170, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
final _orderImg = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 144, 59, 33, 7, 0, 2, 12, 1, 5, 45, 184, 54, 65, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
final _ticketImg = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 144, 147, 59, 1, 0, 1, 98, 1, 5, 17, 27, 163, 33, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
final _pdf = Uint8List.fromList(utf8.encode('%PDF-1.7 e2e letter'));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final backup = BackupController.instance;
  late SupabaseClient client;
  late String uidA;

  BackupRemote remoteFor(String uid) => SupabaseBackupRemote(client, uid);

  Future<BackupManifest?> cloudManifest(String uid) async {
    final json = await remoteFor(uid).downloadManifest();
    return json == null ? null : BackupManifest.parse(json);
  }

  /// A fresh "phone": empty database, files and settings, controller
  /// re-initialised against it. The Supabase session is left as-is.
  Future<void> freshPhone() async {
    await backup.resetForTest();
    await wipeAllLocalData();
    await AppDatabase.resetForTest();
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith('backup_'))) {
      await prefs.remove(k);
    }
    await backup.init();
  }

  Future<void> seedPhone() async {
    final db = AppDatabase.instance;
    final notice = await saveScreenshot(bytes: _noticeImg, hash: hashImageBytes(_noticeImg));
    await db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
      type: 'notice',
      filePath: notice,
      fileHash: hashImageBytes(_noticeImg),
      capturedAt: DateTime(2026, 9, 20, 9, 30),
      notes: const Value('Blocked without reason'),
    ));
    final letter = await saveLetterPdf(bytes: _pdf, fileName: 'letter_e2e.pdf');
    await db.insertLetter(LettersCompanion.insert(
      templateId: 'idBlockReasons',
      lang: 'hindi',
      filePath: letter,
      generatedAt: DateTime(2026, 9, 21, 18),
    ));
    final shot = await saveScreenshot(bytes: _orderImg, hash: hashImageBytes(_orderImg));
    await db.insertOrder(OrdersCompanion.insert(
      platform: 'swiggy',
      orderRef: const Value('SW-62001'),
      timestamp: DateTime(2026, 9, 21, 11, 50),
      basePay: 80,
      incentive: const Value(20),
      tip: const Value(10),
      distanceKm: const Value(3.4),
      sourceScreenshotHash: Value(hashImageBytes(_orderImg)),
      screenshotPath: Value(shot),
    ));
    await db.insertExpense(ExpensesCompanion.insert(
      category: 'fuel',
      amount: 300,
      timestamp: DateTime(2026, 9, 21, 20),
    ));
    await RiderProfile.saveName('E2E Rider');
    await RiderProfile.savePlatforms([GigPlatform.swiggy]);
  }

  Future<void> waitFor(bool Function() condition, {Duration timeout = const Duration(seconds: 60)}) async {
    final end = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(end)) fail('timed out waiting');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  setUpAll(() async {
    expect(_password, isNotEmpty, reason: 'pass --dart-define=E2E_PASSWORD=...');
    await dotenv.load(fileName: '.env');
    await initCloud();
    client = Supabase.instance.client;
    expect(backup.available, isTrue);
    BackupController.autoBackupDelay = const Duration(seconds: 2);
    await backup.signOut();
    await freshPhone();
  });

  testWidgets('1. first sign-in with an empty cloud links and backs up (no earnings)', (tester) async {
    await seedPhone();
    await backup.signInWithPasswordForTest(_emailA, _password);
    uidA = backup.user!.id;
    await waitFor(() => !backup.busy);

    expect(backup.linked, isTrue);
    expect(backup.enabled, isTrue);
    expect(backup.problem, isNull);
    final m = (await cloudManifest(uidA))!;
    expect(m.evidence.single.notes, 'Blocked without reason');
    expect(m.letters.single.lang, 'hindi');
    expect(m.profileName, 'E2E Rider');
    expect(m.includesEarnings, isFalse);
    expect(m.orders, isEmpty);
    final files = await remoteFor(uidA).listFiles();
    expect(files, hasLength(2), reason: 'notice + letter only, no order screenshot');
  });

  testWidgets('2. switching earnings on uploads orders, expenses and screenshots', (tester) async {
    await backup.setIncludeEarnings(true);
    final m = (await cloudManifest(uidA))!;
    expect(m.orders.single.orderRef, 'SW-62001');
    expect(m.expenses.single.amount, 300);
    expect(await remoteFor(uidA).listFiles(), hasLength(3));
  });

  testWidgets('3. a change triggers an automatic backup; deletions are cleaned up', (tester) async {
    final db = AppDatabase.instance;
    final path = await saveScreenshot(bytes: _ticketImg, hash: hashImageBytes(_ticketImg));
    await db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
      type: 'ticket', filePath: path, fileHash: hashImageBytes(_ticketImg), capturedAt: DateTime(2026, 9, 23),
    ));
    await waitFor(() => backup.busy, timeout: const Duration(seconds: 10));
    await waitFor(() => !backup.busy);
    expect((await cloudManifest(uidA))!.evidence, hasLength(2));
    expect(await remoteFor(uidA).listFiles(), contains('${hashImageBytes(_ticketImg)}.jpg'));

    final ticket = (await db.allEvidence()).firstWhere((e) => e.type == 'ticket');
    await db.deleteEvidence(ticket.id);
    await waitFor(() => backup.busy, timeout: const Duration(seconds: 10));
    await waitFor(() => !backup.busy);
    expect((await cloudManifest(uidA))!.evidence, hasLength(1));
    expect(await remoteFor(uidA).listFiles(), isNot(contains('${hashImageBytes(_ticketImg)}.jpg')));
  });

  testWidgets('4. rider B cannot read, list, overwrite or delete rider A\'s backup', (tester) async {
    final other = SupabaseClient(dotenv.get('SUPABASE_URL'), dotenv.get('SUPABASE_PUBLISHABLE_KEY'),
        authOptions: const AuthClientOptions(autoRefreshToken: false));
    await other.auth.signInWithPassword(email: _emailB, password: _password);
    final bucket = other.storage.from(SupabaseBackupRemote.bucket);

    await expectLater(bucket.download('$uidA/manifest.json'), throwsA(isA<StorageException>()));
    expect(await bucket.list(path: '$uidA/files'), isEmpty);
    await expectLater(
      bucket.uploadBinary('$uidA/manifest.json', Uint8List.fromList(utf8.encode('{}')),
          fileOptions: const FileOptions(upsert: true, contentType: 'application/json')),
      throwsA(isA<StorageException>()),
    );
    await bucket.remove(['$uidA/manifest.json']); // silently matches nothing
    // B can't escape via path tricks either.
    await expectLater(
      bucket.uploadBinary('${other.auth.currentUser!.id}/../$uidA/x.json', Uint8List.fromList([1]),
          fileOptions: const FileOptions(contentType: 'application/json')),
      throwsA(anything),
    );
    // Unsigned-in (publishable key only) gets nothing either.
    final anon = SupabaseClient(dotenv.get('SUPABASE_URL'), dotenv.get('SUPABASE_PUBLISHABLE_KEY'));
    await expectLater(
      anon.storage.from(SupabaseBackupRemote.bucket).download('$uidA/manifest.json'),
      throwsA(isA<StorageException>()),
    );

    expect(await cloudManifest(uidA), isNotNull, reason: 'A\'s backup untouched');
    await other.auth.signOut();
  });

  testWidgets('5. a new phone never auto-backs-up over the cloud; restore brings everything back', (tester) async {
    final before = (await cloudManifest(uidA))!;
    await backup.signOut();
    await freshPhone();

    await backup.signInWithPasswordForTest(_emailA, _password);
    expect(backup.awaitingDecision, isTrue);
    expect(backup.cloudBackupAwaitingDecision!.evidence, hasLength(1));

    // Changes on the unlinked phone must not trigger a backup.
    await AppDatabase.instance.insertExpense(ExpensesCompanion.insert(
      category: 'food', amount: 50, timestamp: DateTime(2026, 9, 24),
    ));
    await Future<void>.delayed(const Duration(seconds: 4));
    expect((await cloudManifest(uidA))!.createdAt, before.createdAt);

    expect(backup.includeEarnings, isFalse, reason: 'fresh phone default');
    final report = (await backup.restoreAndLink())!;
    expect(backup.includeEarnings, isTrue, reason: 'carried over from the backup');
    expect(report.damagedFiles, 0);
    expect(report.restoredEvidence, 1);
    expect(report.restoredLetters, 1);
    expect(report.restoredOrders, 1);
    expect(report.restoredExpenses, 1);
    expect(backup.linked, isTrue);

    final db = AppDatabase.instance;
    final ev = (await db.allEvidence()).single;
    expect(await File(ev.filePath).readAsBytes(), _noticeImg);
    expect(await File((await db.allLetters()).single.filePath).readAsBytes(), _pdf);
    final order = (await db.allOrders()).single;
    expect(await File(order.screenshotPath!).readAsBytes(), _orderImg);
    expect(await db.allExpenses(), hasLength(2), reason: 'local expense kept + restored one');
    final profile = await RiderProfile.load();
    expect(profile.name, 'E2E Rider');

    // The merged phone backed up afterwards: cloud now has both expenses.
    await waitFor(() => !backup.busy);
    expect((await cloudManifest(uidA))!.expenses, hasLength(2));
  });

  testWidgets('6. restore on the same phone again is a no-op', (tester) async {
    final r = (await backup.restoreAndLink())!;
    expect(r.restoredTotal, 0);
    expect(await AppDatabase.instance.allEvidence(), hasLength(1));
  });

  testWidgets('7. replace: another phone\'s data replaces the cloud copy and old files go', (tester) async {
    await backup.signOut();
    await freshPhone();
    final path = await saveScreenshot(bytes: _ticketImg, hash: hashImageBytes(_ticketImg));
    await AppDatabase.instance.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
      type: 'payout', filePath: path, fileHash: hashImageBytes(_ticketImg), capturedAt: DateTime(2026, 9, 24),
    ));
    await backup.signInWithPasswordForTest(_emailA, _password);
    expect(backup.awaitingDecision, isTrue);

    await backup.replaceCloudAndLink();
    final m = (await cloudManifest(uidA))!;
    expect(m.evidence.single.type, 'payout');
    expect(m.letters, isEmpty);
    expect(await remoteFor(uidA).listFiles(), {'${hashImageBytes(_ticketImg)}.jpg'});
  });

  testWidgets('8. turning backup off stops sync; with delete it empties the cloud', (tester) async {
    await backup.turnOff(deleteCloudCopy: false);
    await AppDatabase.instance.insertExpense(ExpensesCompanion.insert(
      category: 'toll', amount: 40, timestamp: DateTime(2026, 9, 24),
    ));
    final before = (await cloudManifest(uidA))!.createdAt;
    await Future<void>.delayed(const Duration(seconds: 4));
    expect((await cloudManifest(uidA))!.createdAt, before, reason: 'no sync while off');
    expect(await backup.backupNow(), isNull);

    await backup.turnOn();
    expect((await cloudManifest(uidA))!.createdAt.isAfter(before), isTrue);

    await backup.turnOff(deleteCloudCopy: true);
    expect(await cloudManifest(uidA), isNull);
    expect(await remoteFor(uidA).listFiles(), isEmpty);
    await backup.turnOn();
    expect(await cloudManifest(uidA), isNotNull);
  });

  testWidgets('9. network failure fails cleanly and leaves local data alone', (tester) async {
    final dead = SupabaseClient('https://nonexistent-project.invalid', dotenv.get('SUPABASE_PUBLISHABLE_KEY'));
    final service = BackupService(
      db: AppDatabase.instance,
      docsDir: () async => Directory.systemTemp,
      loadProfile: () async => BackupProfile(name: '', platforms: const []),
      saveProfile: ({String? name, List<String>? platforms}) async {},
    );
    final before = await AppDatabase.instance.allEvidence();
    await expectLater(
      service.backup(SupabaseBackupRemote(dead, uidA), includeEarnings: false),
      throwsA(anything),
    );
    await expectLater(service.restore(SupabaseBackupRemote(dead, uidA)), throwsA(anything));
    expect(await AppDatabase.instance.allEvidence(), hasLength(before.length));
  });

  testWidgets('10. backup screen renders in every language, signed in and awaiting a decision', (tester) async {
    final errors = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').first);
    try {
      await tester.pumpWidget(const AsliKamaiApp());
      await tester.pump(const Duration(seconds: 1));
      final ctx = tester.element(find.byType(RootShell));
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const BackupScreen()));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      for (final textScale in [1.0, 1.3]) {
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        for (final locale in AppLocale.values) {
          await AppLocaleScope.of(tester.element(find.byType(BackupScreen))).setLocale(locale);
          for (var i = 0; i < 10; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.drag(find.byType(Scrollable).first, const Offset(0, 800));
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
      expect(find.byType(SwitchListTile), findsNWidgets(2));
    } finally {
      FlutterError.onError = original;
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await AppLocale.save(AppLocale.english);
    }
    expect(errors, isEmpty, reason: errors.toSet().join('\n'));
  });

  testWidgets('11. delete-account removes rider A\'s files and account', (tester) async {
    await backup.deleteAccount();
    expect(backup.signedIn, isFalse);
    expect(backup.enabled, isFalse);
    await expectLater(
      client.auth.signInWithPassword(email: _emailA, password: _password),
      throwsA(isA<AuthException>()),
    );
  });

  testWidgets('12. rider B: sign in, back up, delete account (cleanup)', (tester) async {
    await freshPhone();
    await backup.signInWithPasswordForTest(_emailB, _password);
    await waitFor(() => !backup.busy);
    expect(backup.linked, isTrue);
    await backup.deleteAccount();
    expect(backup.signedIn, isFalse);
    await wipeAllLocalData();
  });
}
