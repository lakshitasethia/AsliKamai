import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;

import '../../data/database.dart';
import 'backup_manifest.dart';
import 'backup_remote.dart';

/// What a finished backup did, for the Backup screen and tests.
class BackupReport {
  BackupReport({
    required this.manifest,
    required this.uploadedFiles,
    required this.removedFiles,
    required this.missingLocalFiles,
  });

  final BackupManifest manifest;
  final int uploadedFiles;

  /// Cloud files no longer referenced (deleted evidence, earnings switched
  /// off) that this backup removed.
  final int removedFiles;

  /// Evidence/letters whose file had vanished from the phone; left out.
  final int missingLocalFiles;
}

class RestoreReport {
  RestoreReport({
    required this.restoredEvidence,
    required this.restoredLetters,
    required this.restoredOrders,
    required this.restoredExpenses,
    required this.alreadyOnPhone,
    required this.damagedFiles,
    required this.backupIncludedEarnings,
  });

  final int restoredEvidence;
  final int restoredLetters;
  final int restoredOrders;
  final int restoredExpenses;

  /// Rows skipped because the phone already had them (restore merges, it
  /// never replaces — running it twice is harmless).
  final int alreadyOnPhone;

  /// Files that failed their SHA-256 check or couldn't be downloaded. Their
  /// evidence/letter rows are skipped; orders are kept without the image.
  final int damagedFiles;

  /// Whether the rider had "also back up orders & expenses" on when this
  /// backup was made — a new phone should carry that choice over, or its
  /// first backup would drop their earnings from the cloud.
  final bool backupIncludedEarnings;

  int get restoredTotal =>
      restoredEvidence + restoredLetters + restoredOrders + restoredExpenses;
}

class NoBackupFound implements Exception {
  @override
  String toString() => 'NoBackupFound';
}

/// Profile fields, passed in rather than read from SharedPreferences
/// directly so tests don't need a plugin.
class BackupProfile {
  BackupProfile({required this.name, required this.platforms});
  final String name;
  final List<String> platforms;
}

/// Snapshot backup/restore of the local database + files to one rider's
/// [BackupRemote] (build_execution.md Phase 9). Stateless: scheduling,
/// sign-in and settings live in BackupController.
class BackupService {
  BackupService({
    required this.db,
    required this.docsDir,
    required this.loadProfile,
    required this.saveProfile,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final Future<Directory> Function() docsDir;
  final Future<BackupProfile> Function() loadProfile;

  /// Only called with the fields the phone was missing.
  final Future<void> Function({String? name, List<String>? platforms}) saveProfile;
  final DateTime Function() _clock;

  Future<BackupReport> backup(
    BackupRemote remote, {
    required bool includeEarnings,
  }) async {
    final docs = await docsDir();
    final profile = await loadProfile();
    final bytesByRemote = <String, Uint8List>{};
    var missing = 0;

    Future<BackupFileRef?> ref(String? path, String defaultDir) async {
      if (path == null) return null;
      final file = File(path);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      final parent = p.basename(p.dirname(path));
      final underDocs = p.isWithin(docs.path, path);
      final r = BackupFileRef(
        dir: underDocs && BackupFileRef.allowedDirs.contains(parent) ? parent : defaultDir,
        name: _safeLocalName(p.basename(path)),
        sha256: sha256.convert(bytes).toString(),
      );
      bytesByRemote[r.remoteName] = bytes;
      return r;
    }

    final evidence = <BackupEvidence>[];
    for (final e in await db.allEvidence()) {
      final file = await ref(e.filePath, 'screenshots');
      if (file == null) {
        missing++;
        continue;
      }
      evidence.add(BackupEvidence(
        type: e.type,
        fileHash: e.fileHash,
        capturedAt: e.capturedAt,
        documentDate: e.documentDate,
        notes: e.notes,
        file: file,
      ));
    }

    final letters = <BackupLetter>[];
    for (final l in await db.allLetters()) {
      final file = await ref(l.filePath, 'letters');
      if (file == null) {
        missing++;
        continue;
      }
      letters.add(BackupLetter(
        templateId: l.templateId,
        lang: l.lang,
        generatedAt: l.generatedAt,
        file: file,
      ));
    }

    final orders = <BackupOrder>[];
    final expenses = <BackupExpense>[];
    if (includeEarnings) {
      for (final o in await db.allOrders()) {
        orders.add(BackupOrder(
          platform: o.platform,
          orderRef: o.orderRef,
          timestamp: o.timestamp,
          basePay: o.basePay,
          incentive: o.incentive,
          tip: o.tip,
          distanceKm: o.distanceKm,
          durationMin: o.durationMin,
          zone: o.zone,
          sourceScreenshotHash: o.sourceScreenshotHash,
          // A missing screenshot isn't fatal for an order: its pay figures
          // are the data; the image is supporting proof.
          file: await ref(o.screenshotPath, 'screenshots'),
        ));
      }
      for (final e in await db.allExpenses()) {
        expenses.add(BackupExpense(
          category: e.category,
          amount: e.amount,
          rawText: e.rawText,
          timestamp: e.timestamp,
        ));
      }
    }

    final manifest = BackupManifest(
      createdAt: _clock(),
      includesEarnings: includeEarnings,
      profileName: profile.name,
      profilePlatforms: profile.platforms,
      evidence: evidence,
      letters: letters,
      orders: orders,
      expenses: expenses,
    );

    // Files first, manifest last: a manifest in the cloud must never point
    // at a file that isn't there yet, even if this backup dies halfway.
    final existing = await remote.listFiles();
    var uploaded = 0;
    for (final entry in bytesByRemote.entries) {
      if (existing.contains(entry.key)) continue;
      await remote.uploadFile(entry.key, entry.value, sniffContentType(entry.value));
      uploaded++;
    }
    await remote.uploadManifest(manifest.toJsonString());

    // Only now is it safe to drop files the new manifest no longer needs.
    final stale = existing.difference(bytesByRemote.keys.toSet()).toList();
    if (stale.isNotEmpty) await remote.removeFiles(stale);

    return BackupReport(
      manifest: manifest,
      uploadedFiles: uploaded,
      removedFiles: stale.length,
      missingLocalFiles: missing,
    );
  }

  /// The cloud backup's manifest, or null if there is none. Throws
  /// [FormatException] / [UnsupportedBackupVersion] for unreadable ones.
  Future<BackupManifest?> peek(BackupRemote remote) async {
    final json = await remote.downloadManifest();
    if (json == null) return null;
    return _parse(json);
  }

  /// Merges the cloud backup into this phone. Never deletes or overwrites
  /// local rows; idempotent, so an interrupted restore can simply be run
  /// again.
  Future<RestoreReport> restore(BackupRemote remote) async {
    final json = await remote.downloadManifest();
    if (json == null) throw NoBackupFound();
    final manifest = _parse(json);
    final docs = await docsDir();

    // Download + verify each distinct file once.
    final restoredPaths = <String, String>{}; // remoteName -> local path
    var damaged = 0;
    for (final entry in manifest.files.entries) {
      final ref = entry.value;
      var target = File(p.join(docs.path, ref.dir, ref.name));
      if (await target.exists()) {
        if (sha256.convert(await target.readAsBytes()).toString() == ref.sha256) {
          restoredPaths[entry.key] = target.path;
          continue;
        }
        // Same name, different bytes: a different local file. Never
        // overwrite it — restore alongside under a hash-suffixed name.
        target = File(p.join(
          docs.path,
          ref.dir,
          '${p.basenameWithoutExtension(ref.name)}_${ref.sha256.substring(0, 12)}'
          '${p.extension(ref.name)}',
        ));
      }
      Uint8List bytes;
      try {
        bytes = await remote.downloadFile(entry.key);
      } on Exception catch (e) {
        if (_isNotFound(e)) {
          damaged++;
          continue;
        }
        rethrow; // network trouble: fail the restore, it can be re-run
      }
      if (sha256.convert(bytes).toString() != ref.sha256) {
        damaged++;
        continue;
      }
      await target.parent.create(recursive: true);
      await target.writeAsBytes(bytes, flush: true);
      restoredPaths[entry.key] = target.path;
    }

    var evidenceCount = 0, letterCount = 0, orderCount = 0, expenseCount = 0;
    var already = 0;

    for (final e in manifest.evidence) {
      final path = restoredPaths[e.file.remoteName];
      if (path == null) continue;
      final inserted = await db.insertEvidenceIfNew(EvidenceItemsCompanion.insert(
        type: e.type,
        filePath: path,
        fileHash: e.fileHash,
        capturedAt: e.capturedAt,
        documentDate: Value(e.documentDate),
        notes: Value(e.notes),
      ));
      inserted ? evidenceCount++ : already++;
    }

    final localLetters = List.of(await db.allLetters());
    for (final l in manifest.letters) {
      final path = restoredPaths[l.file.remoteName];
      if (path == null) continue;
      final exists = localLetters.any((x) =>
          x.templateId == l.templateId &&
          x.lang == l.lang &&
          x.generatedAt.isAtSameMomentAs(l.generatedAt));
      if (exists) {
        already++;
        continue;
      }
      final id = await db.insertLetter(LettersCompanion.insert(
        templateId: l.templateId,
        lang: l.lang,
        filePath: path,
        generatedAt: l.generatedAt,
      ));
      localLetters.add(await db.letterById(id));
      letterCount++;
    }

    final localOrders = List.of(await db.allOrders());
    for (final o in manifest.orders) {
      final duplicate = o.sourceScreenshotHash != null
          ? localOrders.any((x) => x.sourceScreenshotHash == o.sourceScreenshotHash)
          : localOrders.any((x) =>
              x.sourceScreenshotHash == null &&
              x.platform == o.platform &&
              x.orderRef == o.orderRef &&
              x.basePay == o.basePay &&
              x.timestamp.isAtSameMomentAs(o.timestamp));
      if (duplicate) {
        already++;
        continue;
      }
      final companion = OrdersCompanion.insert(
        platform: o.platform,
        orderRef: Value(o.orderRef),
        timestamp: o.timestamp,
        basePay: o.basePay,
        incentive: Value(o.incentive),
        tip: Value(o.tip),
        distanceKm: Value(o.distanceKm),
        durationMin: Value(o.durationMin),
        zone: Value(o.zone),
        sourceScreenshotHash: Value(o.sourceScreenshotHash),
        screenshotPath: Value(o.file == null ? null : restoredPaths[o.file!.remoteName]),
      );
      final id = await db.insertOrder(companion);
      // Track it so a duplicate later in the same manifest is caught too.
      localOrders.add(await db.orderById(id));
      orderCount++;
    }

    final localExpenses = List.of(await db.allExpenses());
    for (final e in manifest.expenses) {
      final duplicate = localExpenses.any((x) =>
          x.category == e.category &&
          x.amount == e.amount &&
          x.timestamp.isAtSameMomentAs(e.timestamp));
      if (duplicate) {
        already++;
        continue;
      }
      final id = await db.insertExpense(ExpensesCompanion.insert(
        category: e.category,
        amount: e.amount,
        rawText: Value(e.rawText),
        timestamp: e.timestamp,
      ));
      localExpenses.add(await db.expenseById(id));
      expenseCount++;
    }

    // Fill in the profile only where this phone has nothing — a name the
    // rider already typed here wins over the backed-up one.
    final local = await loadProfile();
    await saveProfile(
      name: local.name.isEmpty && manifest.profileName.isNotEmpty ? manifest.profileName : null,
      platforms: local.platforms.isEmpty && manifest.profilePlatforms.isNotEmpty
          ? manifest.profilePlatforms
          : null,
    );

    return RestoreReport(
      restoredEvidence: evidenceCount,
      restoredLetters: letterCount,
      restoredOrders: orderCount,
      restoredExpenses: expenseCount,
      alreadyOnPhone: already,
      damagedFiles: damaged,
      backupIncludedEarnings: manifest.includesEarnings,
    );
  }

  /// Deletes this rider's whole cloud backup. Manifest first, so a
  /// half-finished delete never leaves a manifest pointing at missing files.
  Future<void> deleteCloudCopy(BackupRemote remote) async {
    await remote.removeManifest();
    final files = await remote.listFiles();
    if (files.isNotEmpty) await remote.removeFiles(files.toList());
  }

  BackupManifest _parse(String json) {
    try {
      return BackupManifest.parse(json);
    } on TypeError {
      throw const FormatException('manifest has a field of the wrong type');
    }
  }
}

bool _isNotFound(Exception e) {
  final s = e.toString().toLowerCase();
  return s.contains('not found') || s.contains('404');
}

/// Local names are `<hash>.jpg` / `letter_….pdf`; anything else (a file
/// with spaces etc.) is renamed so it passes [BackupFileRef]'s checks.
String _safeLocalName(String name) {
  final cleaned = name
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
      .replaceAll(RegExp(r'\.{2,}'), '.');
  var trimmed = cleaned.replaceFirst(RegExp(r'^[._-]+'), '');
  if (p.basenameWithoutExtension(trimmed).isEmpty) trimmed = 'file$trimmed';
  final ext = p.extension(trimmed).toLowerCase();
  final withExt = BackupFileRef.allowedExtensions.contains(ext) ? trimmed : '$trimmed.jpg';
  return withExt.length > 128 ? withExt.substring(withExt.length - 128) : withExt;
}

/// The real type from the bytes — screenshots are saved as `.jpg` whatever
/// they actually are, and the bucket only accepts known types.
String sniffContentType(List<int> b) {
  bool starts(List<int> sig) =>
      b.length >= sig.length && List.generate(sig.length, (i) => b[i] == sig[i]).every((x) => x);
  if (starts([0x89, 0x50, 0x4E, 0x47])) return 'image/png';
  if (starts([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (starts([0x25, 0x50, 0x44, 0x46])) return 'application/pdf';
  if (b.length >= 12 &&
      starts([0x52, 0x49, 0x46, 0x46]) &&
      b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
    return 'image/webp';
  }
  return 'application/octet-stream';
}
