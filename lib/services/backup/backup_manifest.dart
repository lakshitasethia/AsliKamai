import 'dart:convert';

import 'package:path/path.dart' as p;

/// A file a backed-up row points at. Stored in the cloud content-addressed
/// as `<sha256><ext>` and restored to `<app docs>/<dir>/<name>`.
class BackupFileRef {
  BackupFileRef({required this.dir, required this.name, required this.sha256});

  /// Sub-folders of the app's documents directory a restore may write into.
  static const allowedDirs = {'screenshots', 'letters'};
  static const allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp', '.pdf'};
  static final _safeName = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$');
  static final _sha256 = RegExp(r'^[0-9a-f]{64}$');

  final String dir;
  final String name;
  final String sha256;

  String get remoteName => '$sha256${p.extension(name).toLowerCase()}';

  Map<String, Object?> toJson() => {'dir': dir, 'name': name, 'sha256': sha256};

  /// Rejects anything that could make a restore write outside the app's own
  /// screenshots/letters folders (`../`, absolute paths, odd extensions) —
  /// the manifest comes from the network, so it's treated as untrusted.
  static BackupFileRef fromJson(Object? json) {
    if (json is! Map) throw const FormatException('file ref is not an object');
    final dir = json['dir'];
    final name = json['name'];
    final sha = json['sha256'];
    if (dir is! String || !allowedDirs.contains(dir)) {
      throw FormatException('bad file dir: $dir');
    }
    if (name is! String || !_safeName.hasMatch(name) || name.contains('..')) {
      throw FormatException('bad file name: $name');
    }
    if (!allowedExtensions.contains(p.extension(name).toLowerCase())) {
      throw FormatException('bad file extension: $name');
    }
    if (sha is! String || !_sha256.hasMatch(sha)) {
      throw FormatException('bad sha256 for $name');
    }
    return BackupFileRef(dir: dir, name: name, sha256: sha);
  }
}

class BackupEvidence {
  BackupEvidence({
    required this.type,
    required this.fileHash,
    required this.capturedAt,
    this.documentDate,
    this.notes,
    required this.file,
  });

  final String type;
  final String fileHash;
  final DateTime capturedAt;
  final DateTime? documentDate;
  final String? notes;
  final BackupFileRef file;

  Map<String, Object?> toJson() => {
        'type': type,
        'fileHash': fileHash,
        'capturedAt': capturedAt.toIso8601String(),
        if (documentDate != null) 'documentDate': documentDate!.toIso8601String(),
        if (notes != null) 'notes': notes,
        'file': file.toJson(),
      };

  static BackupEvidence fromJson(Map<String, Object?> j) => BackupEvidence(
        type: _str(j, 'type'),
        fileHash: _str(j, 'fileHash'),
        capturedAt: _date(j, 'capturedAt'),
        documentDate: _dateOrNull(j, 'documentDate'),
        notes: _strOrNull(j, 'notes'),
        file: BackupFileRef.fromJson(j['file']),
      );
}

class BackupLetter {
  BackupLetter({
    required this.templateId,
    required this.lang,
    required this.generatedAt,
    required this.file,
  });

  final String templateId;
  final String lang;
  final DateTime generatedAt;
  final BackupFileRef file;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'lang': lang,
        'generatedAt': generatedAt.toIso8601String(),
        'file': file.toJson(),
      };

  static BackupLetter fromJson(Map<String, Object?> j) => BackupLetter(
        templateId: _str(j, 'templateId'),
        lang: _str(j, 'lang'),
        generatedAt: _date(j, 'generatedAt'),
        file: BackupFileRef.fromJson(j['file']),
      );
}

class BackupOrder {
  BackupOrder({
    required this.platform,
    this.orderRef,
    required this.timestamp,
    required this.basePay,
    required this.incentive,
    required this.tip,
    this.distanceKm,
    this.durationMin,
    this.zone,
    this.sourceScreenshotHash,
    this.file,
  });

  final String platform;
  final String? orderRef;
  final DateTime timestamp;
  final double basePay;
  final double incentive;
  final double tip;
  final double? distanceKm;
  final int? durationMin;
  final String? zone;
  final String? sourceScreenshotHash;

  /// The order's source screenshot, when it was still on the phone.
  final BackupFileRef? file;

  Map<String, Object?> toJson() => {
        'platform': platform,
        if (orderRef != null) 'orderRef': orderRef,
        'timestamp': timestamp.toIso8601String(),
        'basePay': basePay,
        'incentive': incentive,
        'tip': tip,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (durationMin != null) 'durationMin': durationMin,
        if (zone != null) 'zone': zone,
        if (sourceScreenshotHash != null) 'sourceScreenshotHash': sourceScreenshotHash,
        if (file != null) 'file': file!.toJson(),
      };

  static BackupOrder fromJson(Map<String, Object?> j) => BackupOrder(
        platform: _str(j, 'platform'),
        orderRef: _strOrNull(j, 'orderRef'),
        timestamp: _date(j, 'timestamp'),
        basePay: _num(j, 'basePay'),
        incentive: _numOr(j, 'incentive', 0),
        tip: _numOr(j, 'tip', 0),
        distanceKm: (j['distanceKm'] as num?)?.toDouble(),
        durationMin: (j['durationMin'] as num?)?.toInt(),
        zone: _strOrNull(j, 'zone'),
        sourceScreenshotHash: _strOrNull(j, 'sourceScreenshotHash'),
        file: j['file'] == null ? null : BackupFileRef.fromJson(j['file']),
      );
}

class BackupExpense {
  BackupExpense({
    required this.category,
    required this.amount,
    this.rawText,
    required this.timestamp,
  });

  final String category;
  final double amount;
  final String? rawText;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
        'category': category,
        'amount': amount,
        if (rawText != null) 'rawText': rawText,
        'timestamp': timestamp.toIso8601String(),
      };

  static BackupExpense fromJson(Map<String, Object?> j) => BackupExpense(
        category: _str(j, 'category'),
        amount: _num(j, 'amount'),
        rawText: _strOrNull(j, 'rawText'),
        timestamp: _date(j, 'timestamp'),
      );
}

/// Thrown when the cloud backup was written by a newer app version whose
/// format this build doesn't understand — the rider needs to update.
class UnsupportedBackupVersion implements Exception {
  UnsupportedBackupVersion(this.version);
  final int version;

  @override
  String toString() => 'UnsupportedBackupVersion($version)';
}

/// Everything a backup holds besides the file bytes: `manifest.json`.
/// Orders/expenses are only present when the rider opted into backing up
/// earnings (research.md: earnings never leave the phone by default).
class BackupManifest {
  BackupManifest({
    required this.createdAt,
    required this.includesEarnings,
    required this.profileName,
    required this.profilePlatforms,
    required this.evidence,
    required this.letters,
    required this.orders,
    required this.expenses,
  });

  static const format = 'asli_kamai_backup';
  static const currentVersion = 1;

  final DateTime createdAt;
  final bool includesEarnings;
  final String profileName;
  final List<String> profilePlatforms;
  final List<BackupEvidence> evidence;
  final List<BackupLetter> letters;
  final List<BackupOrder> orders;
  final List<BackupExpense> expenses;

  /// Every file the rows reference, keyed by cloud name (deduplicated: the
  /// rate-cut evidence photo and its order's screenshot are the same file).
  Map<String, BackupFileRef> get files => {
        for (final e in evidence) e.file.remoteName: e.file,
        for (final l in letters) l.file.remoteName: l.file,
        for (final o in orders)
          if (o.file != null) o.file!.remoteName: o.file!,
      };

  String toJsonString() => jsonEncode({
        'format': format,
        'version': currentVersion,
        'createdAt': createdAt.toIso8601String(),
        'includesEarnings': includesEarnings,
        'profile': {'name': profileName, 'platforms': profilePlatforms},
        'evidence': evidence.map((e) => e.toJson()).toList(),
        'letters': letters.map((l) => l.toJson()).toList(),
        if (includesEarnings) ...{
          'orders': orders.map((o) => o.toJson()).toList(),
          'expenses': expenses.map((e) => e.toJson()).toList(),
        },
      });

  /// Throws [FormatException] for anything malformed and
  /// [UnsupportedBackupVersion] for a backup from a newer app.
  static BackupManifest parse(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('manifest is not valid JSON');
    }
    if (decoded is! Map<String, Object?> || decoded['format'] != format) {
      throw const FormatException('not an AsliKamai backup');
    }
    final version = decoded['version'];
    if (version is! int) throw const FormatException('missing version');
    if (version > currentVersion) throw UnsupportedBackupVersion(version);

    final profile = decoded['profile'];
    final includesEarnings = decoded['includesEarnings'] == true;
    return BackupManifest(
      createdAt: _date(decoded, 'createdAt'),
      includesEarnings: includesEarnings,
      profileName: profile is Map ? (profile['name'] as String? ?? '') : '',
      profilePlatforms: profile is Map
          ? ((profile['platforms'] as List?) ?? const []).whereType<String>().toList()
          : const [],
      evidence: _list(decoded, 'evidence', BackupEvidence.fromJson),
      letters: _list(decoded, 'letters', BackupLetter.fromJson),
      orders: includesEarnings ? _list(decoded, 'orders', BackupOrder.fromJson) : const [],
      expenses: includesEarnings ? _list(decoded, 'expenses', BackupExpense.fromJson) : const [],
    );
  }
}

List<T> _list<T>(
  Map<String, Object?> j,
  String key,
  T Function(Map<String, Object?>) parse,
) {
  final raw = j[key];
  if (raw == null) return const [];
  if (raw is! List) throw FormatException('$key is not a list');
  return [
    for (final item in raw)
      if (item is Map<String, Object?>)
        parse(item)
      else
        throw FormatException('$key entry is not an object'),
  ];
}

String _str(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v is! String) throw FormatException('missing $key');
  return v;
}

String? _strOrNull(Map<String, Object?> j, String key) {
  final v = j[key];
  return v is String ? v : null;
}

double _num(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v is! num) throw FormatException('missing $key');
  return v.toDouble();
}

double _numOr(Map<String, Object?> j, String key, double fallback) =>
    (j[key] as num?)?.toDouble() ?? fallback;

DateTime _date(Map<String, Object?> j, String key) {
  final v = DateTime.tryParse(_str(j, key));
  if (v == null) throw FormatException('bad date in $key');
  return v;
}

DateTime? _dateOrNull(Map<String, Object?> j, String key) {
  final v = j[key];
  return v is String ? DateTime.tryParse(v) : null;
}
