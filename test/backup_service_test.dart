import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/services/backup/backup_manifest.dart';
import 'package:asli_kamai/services/backup/backup_remote.dart';
import 'package:asli_kamai/services/backup/backup_service.dart';

/// In-memory stand-in for one rider's Supabase folder, with failure
/// injection for the network-trouble edge cases.
class FakeRemote implements BackupRemote {
  final files = <String, Uint8List>{};
  final contentTypes = <String, String>{};
  String? manifest;
  int uploads = 0;

  /// Upload/download calls left before a simulated network failure.
  int? failUploadsAfter;
  int? failDownloadsAfter;

  void _maybeFail(int? Function() get, void Function(int?) set) {
    final left = get();
    if (left == null) return;
    if (left <= 0) throw const SocketException('network down');
    set(left - 1);
  }

  @override
  Future<Set<String>> listFiles() async => files.keys.toSet();

  @override
  Future<void> uploadFile(String name, Uint8List bytes, String contentType) async {
    _maybeFail(() => failUploadsAfter, (v) => failUploadsAfter = v);
    files[name] = bytes;
    contentTypes[name] = contentType;
    uploads++;
  }

  @override
  Future<Uint8List> downloadFile(String name) async {
    _maybeFail(() => failDownloadsAfter, (v) => failDownloadsAfter = v);
    final f = files[name];
    if (f == null) throw Exception('Object not found');
    return f;
  }

  @override
  Future<void> removeFiles(List<String> names) async => names.forEach(files.remove);

  @override
  Future<String?> downloadManifest() async => manifest;

  @override
  Future<void> uploadManifest(String json) async {
    _maybeFail(() => failUploadsAfter, (v) => failUploadsAfter = v);
    manifest = json;
  }

  @override
  Future<void> removeManifest() async => manifest = null;
}

/// One "phone": its own database, documents folder and profile.
class Phone {
  Phone(this.docs) : db = AppDatabase.forTesting();

  final Directory docs;
  final AppDatabase db;
  String name = '';
  List<String> platforms = [];

  late final service = BackupService(
    db: db,
    docsDir: () async => docs,
    loadProfile: () async => BackupProfile(name: name, platforms: platforms),
    saveProfile: ({String? name, List<String>? platforms}) async {
      if (name != null) this.name = name;
      if (platforms != null) this.platforms = platforms;
    },
    clock: () => DateTime(2026, 9, 24, 10),
  );

  Future<String> writeFile(String dir, String fileName, List<int> bytes) async {
    final f = File(p.join(docs.path, dir, fileName));
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes);
    return f.path;
  }
}

final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 1, 2, 3]);
final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 9, 9, 9]);
final pdfBytes = Uint8List.fromList(utf8.encode('%PDF-1.7 letter'));
String sha(List<int> b) => sha256.convert(b).toString();

void main() {
  late Directory tmp;
  late Phone phone;
  late FakeRemote remote;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('backup_test');
    phone = Phone(Directory(p.join(tmp.path, 'phoneA'))..createSync());
    remote = FakeRemote();
  });

  tearDown(() async {
    await phone.db.close();
    await tmp.delete(recursive: true);
  });

  /// A notice photo (really a PNG, saved as .jpg like the app does), a
  /// letter PDF, an order with its screenshot and an expense.
  Future<void> seed(Phone ph) async {
    final noticePath = await ph.writeFile('screenshots', '${sha(pngBytes)}.jpg', pngBytes);
    await ph.db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
      type: 'notice',
      filePath: noticePath,
      fileHash: sha(pngBytes),
      capturedAt: DateTime(2026, 9, 20, 9, 30),
      documentDate: Value(DateTime(2026, 9, 19)),
      notes: const Value('ID blocked'),
    ));
    final letterPath = await ph.writeFile('letters', 'letter_idBlockReasons_1.pdf', pdfBytes);
    await ph.db.insertLetter(LettersCompanion.insert(
      templateId: 'idBlockReasons',
      lang: 'kannada',
      filePath: letterPath,
      generatedAt: DateTime(2026, 9, 21, 18),
    ));
    final orderShot = await ph.writeFile('screenshots', '${sha(jpegBytes)}.jpg', jpegBytes);
    await ph.db.insertOrder(OrdersCompanion.insert(
      platform: 'swiggy',
      orderRef: const Value('SW-62001'),
      timestamp: DateTime(2026, 9, 21, 11, 50),
      basePay: 80,
      incentive: const Value(20),
      tip: const Value(10),
      distanceKm: const Value(3.4),
      durationMin: const Value(19),
      zone: const Value('Koramangala'),
      sourceScreenshotHash: Value(sha(jpegBytes)),
      screenshotPath: Value(orderShot),
    ));
    await ph.db.insertExpense(ExpensesCompanion.insert(
      category: 'fuel',
      amount: 300,
      rawText: const Value('petrol 300'),
      timestamp: DateTime(2026, 9, 21, 20),
    ));
    ph.name = 'Ravi Kumar';
    ph.platforms = ['swiggy', 'zomato'];
  }

  group('backup', () {
    test('uploads evidence + letters + profile, but not earnings by default', () async {
      await seed(phone);
      final report = await phone.service.backup(remote, includeEarnings: false);

      expect(report.uploadedFiles, 2);
      expect(remote.files.keys, unorderedEquals(['${sha(pngBytes)}.jpg', '${sha(pdfBytes)}.pdf']));
      final json = jsonDecode(remote.manifest!) as Map<String, dynamic>;
      expect(json.containsKey('orders'), isFalse);
      expect(json.containsKey('expenses'), isFalse);
      expect(json['profile'], {'name': 'Ravi Kumar', 'platforms': ['swiggy', 'zomato']});
      expect(remote.manifest, isNot(contains('SW-62001')));
      expect(remote.manifest, isNot(contains('petrol')));
    });

    test('sends the real content type, not the .jpg the file is named with', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      expect(remote.contentTypes['${sha(pngBytes)}.jpg'], 'image/png');
      expect(remote.contentTypes['${sha(jpegBytes)}.jpg'], 'image/jpeg');
      expect(remote.contentTypes['${sha(pdfBytes)}.pdf'], 'application/pdf');
    });

    test('includes orders, expenses and order screenshots when opted in', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      final m = BackupManifest.parse(remote.manifest!);
      expect(m.orders.single.orderRef, 'SW-62001');
      expect(m.orders.single.basePay, 80);
      expect(m.expenses.single.amount, 300);
      expect(remote.files.containsKey('${sha(jpegBytes)}.jpg'), isTrue);
    });

    test('is incremental: an unchanged second backup uploads nothing', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      final uploadsBefore = remote.uploads;
      final second = await phone.service.backup(remote, includeEarnings: true);
      expect(second.uploadedFiles, 0);
      expect(remote.uploads, uploadsBefore);
    });

    test('a file shared by evidence and an order is uploaded once', () async {
      await seed(phone);
      final order = (await phone.db.allOrders()).single;
      // Rate-cut auto-save: evidence pointing at the order's own screenshot.
      await phone.db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
        type: 'payout',
        filePath: order.screenshotPath!,
        fileHash: sha(jpegBytes),
        capturedAt: DateTime(2026, 9, 22),
      ));
      final report = await phone.service.backup(remote, includeEarnings: true);
      expect(report.uploadedFiles, 3);
      expect(remote.files.length, 3);
    });

    test('deleted evidence is removed from the cloud on the next backup', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: false);
      final ev = (await phone.db.allEvidence()).single;
      await phone.db.deleteEvidence(ev.id);

      final report = await phone.service.backup(remote, includeEarnings: false);
      expect(report.removedFiles, 1);
      expect(remote.files.containsKey('${sha(pngBytes)}.jpg'), isFalse);
      expect(BackupManifest.parse(remote.manifest!).evidence, isEmpty);
    });

    test('switching earnings off removes orders and their screenshots from the cloud', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      expect(remote.files.containsKey('${sha(jpegBytes)}.jpg'), isTrue);

      await phone.service.backup(remote, includeEarnings: false);
      expect(remote.files.containsKey('${sha(jpegBytes)}.jpg'), isFalse);
      expect(remote.manifest, isNot(contains('SW-62001')));
    });

    test('rows whose file vanished from the phone are skipped, not fatal', () async {
      await seed(phone);
      await File((await phone.db.allLetters()).single.filePath).delete();
      final order = (await phone.db.allOrders()).single;
      await File(order.screenshotPath!).delete();

      final report = await phone.service.backup(remote, includeEarnings: true);
      final m = BackupManifest.parse(remote.manifest!);
      expect(report.missingLocalFiles, 1);
      expect(m.letters, isEmpty);
      expect(m.evidence, hasLength(1));
      // The order's pay data still matters without its screenshot.
      expect(m.orders.single.file, isNull);
    });

    test('an empty phone produces a valid, empty backup', () async {
      final report = await phone.service.backup(remote, includeEarnings: true);
      expect(report.uploadedFiles, 0);
      final m = BackupManifest.parse(remote.manifest!);
      expect(m.evidence, isEmpty);
      expect(m.orders, isEmpty);
    });

    test('network failure mid-upload leaves the previous manifest intact', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: false);
      final goodManifest = remote.manifest;

      // New evidence, then the network dies on the first upload.
      final newShot = Uint8List.fromList([0xFF, 0xD8, 0xFF, 7, 7]);
      final path = await phone.writeFile('screenshots', '${sha(newShot)}.jpg', newShot);
      await phone.db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
        type: 'ticket', filePath: path, fileHash: sha(newShot), capturedAt: DateTime(2026, 9, 23),
      ));
      remote.failUploadsAfter = 0;
      await expectLater(
        phone.service.backup(remote, includeEarnings: false),
        throwsA(isA<SocketException>()),
      );
      expect(remote.manifest, goodManifest);
      // Every file the surviving manifest names is still there.
      for (final f in BackupManifest.parse(remote.manifest!).files.keys) {
        expect(remote.files.containsKey(f), isTrue);
      }

      remote.failUploadsAfter = null;
      await phone.service.backup(remote, includeEarnings: false);
      expect(BackupManifest.parse(remote.manifest!).evidence, hasLength(2));
    });

    test('odd local file names are made safe for the manifest', () async {
      final path = await phone.writeFile('letters', 'my letter (1)..pdf', pdfBytes);
      await phone.db.insertLetter(LettersCompanion.insert(
        templateId: 'grievanceFiling', lang: 'english', filePath: path, generatedAt: DateTime(2026, 9, 1),
      ));
      await phone.service.backup(remote, includeEarnings: false);
      final m = BackupManifest.parse(remote.manifest!); // would throw if unsafe
      expect(m.letters.single.file.name, 'my_letter__1_.pdf');
    });
  });

  group('restore', () {
    late Phone newPhone;

    setUp(() {
      newPhone = Phone(Directory(p.join(tmp.path, 'phoneB'))..createSync());
    });
    tearDown(() => newPhone.db.close());

    test('restores everything onto a new phone, byte for byte', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);

      final report = await newPhone.service.restore(remote);
      expect(report.restoredEvidence, 1);
      expect(report.restoredLetters, 1);
      expect(report.restoredOrders, 1);
      expect(report.restoredExpenses, 1);
      expect(report.damagedFiles, 0);
      expect(report.backupIncludedEarnings, isTrue);

      final ev = (await newPhone.db.allEvidence()).single;
      expect(p.isWithin(newPhone.docs.path, ev.filePath), isTrue);
      expect(await File(ev.filePath).readAsBytes(), pngBytes);
      expect(ev.fileHash, sha(pngBytes));
      expect(ev.notes, 'ID blocked');
      expect(ev.documentDate, DateTime(2026, 9, 19));
      expect(ev.capturedAt, DateTime(2026, 9, 20, 9, 30));

      final letter = (await newPhone.db.allLetters()).single;
      expect(await File(letter.filePath).readAsBytes(), pdfBytes);
      expect(letter.lang, 'kannada');

      final order = (await newPhone.db.allOrders()).single;
      expect(order.basePay, 80);
      expect(order.distanceKm, 3.4);
      expect(await File(order.screenshotPath!).readAsBytes(), jpegBytes);
      expect((await newPhone.db.allExpenses()).single.rawText, 'petrol 300');

      expect(newPhone.name, 'Ravi Kumar');
      expect(newPhone.platforms, ['swiggy', 'zomato']);
    });

    test('running restore twice adds nothing the second time', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      await newPhone.service.restore(remote);
      final again = await newPhone.service.restore(remote);

      expect(again.restoredTotal, 0);
      expect(again.alreadyOnPhone, 4);
      expect(await newPhone.db.allEvidence(), hasLength(1));
      expect(await newPhone.db.allOrders(), hasLength(1));
      expect(await newPhone.db.allExpenses(), hasLength(1));
      expect(await newPhone.db.allLetters(), hasLength(1));
    });

    test('merges into existing data and keeps the name typed on this phone', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      newPhone.name = 'Ravi K';
      await newPhone.db.insertExpense(ExpensesCompanion.insert(
        category: 'food', amount: 80, timestamp: DateTime(2026, 9, 23),
      ));

      await newPhone.service.restore(remote);
      expect(newPhone.name, 'Ravi K');
      expect(newPhone.platforms, ['swiggy', 'zomato']);
      expect(await newPhone.db.allExpenses(), hasLength(2));
    });

    test('a tampered file fails its hash check: evidence skipped, order kept', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      remote.files['${sha(pngBytes)}.jpg'] = Uint8List.fromList([1, 2, 3]);
      remote.files['${sha(jpegBytes)}.jpg'] = Uint8List.fromList([4, 5, 6]);

      final report = await newPhone.service.restore(remote);
      expect(report.damagedFiles, 2);
      expect(await newPhone.db.allEvidence(), isEmpty);
      final order = (await newPhone.db.allOrders()).single;
      expect(order.screenshotPath, isNull);
      expect(order.basePay, 80);
      // Nothing unverified was written to disk.
      expect(File(p.join(newPhone.docs.path, 'screenshots', '${sha(pngBytes)}.jpg')).existsSync(), isFalse);
    });

    test('a file missing from the cloud is counted, not fatal', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: false);
      remote.files.remove('${sha(pdfBytes)}.pdf');

      final report = await newPhone.service.restore(remote);
      expect(report.backupIncludedEarnings, isFalse);
      expect(report.damagedFiles, 1);
      expect(report.restoredEvidence, 1);
      expect(await newPhone.db.allLetters(), isEmpty);
    });

    test('network failure mid-restore throws; re-running finishes without duplicates', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: true);
      remote.failDownloadsAfter = 1;
      await expectLater(newPhone.service.restore(remote), throwsA(isA<SocketException>()));

      remote.failDownloadsAfter = null;
      await newPhone.service.restore(remote);
      await newPhone.service.restore(remote);
      expect(await newPhone.db.allEvidence(), hasLength(1));
      expect(await newPhone.db.allLetters(), hasLength(1));
      expect(await newPhone.db.allOrders(), hasLength(1));
    });

    test('never overwrites a different local file with the same name', () async {
      await seed(phone);
      await phone.service.backup(remote, includeEarnings: false);
      final mine = Uint8List.fromList(utf8.encode('%PDF my other letter'));
      final clash = await newPhone.writeFile('letters', 'letter_idBlockReasons_1.pdf', mine);

      await newPhone.service.restore(remote);
      expect(await File(clash).readAsBytes(), mine);
      final restored = (await newPhone.db.allLetters()).single;
      expect(restored.filePath, isNot(clash));
      expect(await File(restored.filePath).readAsBytes(), pdfBytes);
    });

    test('no backup in the cloud → NoBackupFound, and peek is null', () async {
      expect(await newPhone.service.peek(remote), isNull);
      await expectLater(newPhone.service.restore(remote), throwsA(isA<NoBackupFound>()));
    });

    test('a backup from a newer app version is refused, not half-read', () async {
      remote.manifest = jsonEncode({
        'format': BackupManifest.format,
        'version': BackupManifest.currentVersion + 1,
        'createdAt': '2026-09-24T10:00:00.000',
      });
      await expectLater(newPhone.service.restore(remote), throwsA(isA<UnsupportedBackupVersion>()));
      await expectLater(newPhone.service.peek(remote), throwsA(isA<UnsupportedBackupVersion>()));
    });

    test('garbage or wrongly-typed manifests are FormatExceptions', () async {
      for (final bad in [
        'not json',
        '[]',
        jsonEncode({'format': 'something_else', 'version': 1}),
        jsonEncode({'format': BackupManifest.format, 'version': 1, 'createdAt': 'yesterday'}),
        jsonEncode({
          'format': BackupManifest.format, 'version': 1, 'createdAt': '2026-09-24T10:00:00',
          'includesEarnings': true,
          'orders': [{'platform': 'swiggy', 'timestamp': '2026-09-24T10:00:00', 'basePay': '80'}],
        }),
        jsonEncode({
          'format': BackupManifest.format, 'version': 1, 'createdAt': '2026-09-24T10:00:00',
          'includesEarnings': true,
          'orders': [{'platform': 'swiggy', 'timestamp': '2026-09-24T10:00:00', 'basePay': 80, 'distanceKm': 'far'}],
        }),
      ]) {
        remote.manifest = bad;
        await expectLater(newPhone.service.restore(remote), throwsA(isA<FormatException>()), reason: bad);
      }
      expect(await newPhone.db.allOrders(), isEmpty);
    });

    test('a manifest trying to write outside the app folders is rejected', () async {
      for (final ref in [
        {'dir': '../../databases', 'name': 'x.jpg', 'sha256': sha(pngBytes)},
        {'dir': 'screenshots', 'name': '../../asli_kamai.sqlite', 'sha256': sha(pngBytes)},
        {'dir': 'screenshots', 'name': '/etc/passwd.jpg', 'sha256': sha(pngBytes)},
        {'dir': 'screenshots', 'name': 'evil.so', 'sha256': sha(pngBytes)},
        {'dir': 'screenshots', 'name': 'ok.jpg', 'sha256': '../x'},
      ]) {
        remote.manifest = jsonEncode({
          'format': BackupManifest.format, 'version': 1, 'createdAt': '2026-09-24T10:00:00',
          'evidence': [{'type': 'notice', 'fileHash': 'h', 'capturedAt': '2026-09-24T10:00:00', 'file': ref}],
        });
        await expectLater(newPhone.service.restore(remote), throwsA(isA<FormatException>()), reason: '$ref');
      }
      expect(newPhone.docs.listSync(recursive: true), isEmpty);
    });

    test('a manifest without earnings ignores any orders smuggled into it', () async {
      remote.manifest = jsonEncode({
        'format': BackupManifest.format, 'version': 1, 'createdAt': '2026-09-24T10:00:00',
        'includesEarnings': false,
        'orders': [{'platform': 'swiggy', 'timestamp': '2026-09-24T10:00:00', 'basePay': 80}],
      });
      await newPhone.service.restore(remote);
      expect(await newPhone.db.allOrders(), isEmpty);
    });

    test('duplicate hash-less orders inside one backup restore once', () async {
      final dup = {'platform': 'zomato', 'orderRef': 'Z1', 'timestamp': '2026-09-20T10:00:00.000', 'basePay': 50};
      remote.manifest = jsonEncode({
        'format': BackupManifest.format, 'version': 1, 'createdAt': '2026-09-24T10:00:00',
        'includesEarnings': true, 'orders': [dup, dup],
      });
      final report = await newPhone.service.restore(remote);
      expect(report.restoredOrders, 1);
      expect(report.alreadyOnPhone, 1);
    });
  });

  test('deleteCloudCopy removes the manifest and every file', () async {
    await seed(phone);
    await phone.service.backup(remote, includeEarnings: true);
    await phone.service.deleteCloudCopy(remote);
    expect(remote.manifest, isNull);
    expect(remote.files, isEmpty);
  });

  test('sniffContentType', () {
    expect(sniffContentType(pngBytes), 'image/png');
    expect(sniffContentType(jpegBytes), 'image/jpeg');
    expect(sniffContentType(pdfBytes), 'application/pdf');
    expect(sniffContentType(utf8.encode('RIFF1234WEBPVP8 ')), 'image/webp');
    expect(sniffContentType(utf8.encode('RIFF1234WAVE')), 'application/octet-stream');
    expect(sniffContentType([]), 'application/octet-stream');
  });
}
