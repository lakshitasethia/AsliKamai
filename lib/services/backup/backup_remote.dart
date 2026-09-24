import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// One rider's cloud backup folder. Everything lives under
/// `backups/<user id>/`: a `manifest.json` describing the rows, and
/// `files/<sha256>.<ext>` for every screenshot/photo/PDF the rows reference.
/// Abstract so [BackupService] can be tested against an in-memory fake.
abstract class BackupRemote {
  /// Names (e.g. `ab12….jpg`) of every file already in `files/`.
  Future<Set<String>> listFiles();

  Future<void> uploadFile(String name, Uint8List bytes, String contentType);

  Future<Uint8List> downloadFile(String name);

  Future<void> removeFiles(List<String> names);

  /// Null when this rider has never backed up (or deleted their backup).
  Future<String?> downloadManifest();

  Future<void> uploadManifest(String json);

  Future<void> removeManifest();
}

class SupabaseBackupRemote implements BackupRemote {
  SupabaseBackupRemote(this._client, this._userId);

  static const bucket = 'backups';
  static const _pageSize = 1000;

  final SupabaseClient _client;
  final String _userId;

  StorageFileApi get _bucket => _client.storage.from(bucket);
  String get _filesDir => '$_userId/files';
  String get _manifestPath => '$_userId/manifest.json';

  @override
  Future<Set<String>> listFiles() async {
    final names = <String>{};
    for (var offset = 0;; offset += _pageSize) {
      final page = await _bucket.list(
        path: _filesDir,
        searchOptions: SearchOptions(limit: _pageSize, offset: offset),
      );
      names.addAll(page.where((f) => f.id != null).map((f) => f.name));
      if (page.length < _pageSize) return names;
    }
  }

  @override
  Future<void> uploadFile(String name, Uint8List bytes, String contentType) async {
    await _bucket.uploadBinary(
      '$_filesDir/$name',
      bytes,
      // Content-addressed: the same name always means the same bytes, so an
      // upsert after a half-finished earlier attempt is harmless.
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
  }

  @override
  Future<Uint8List> downloadFile(String name) => _bucket.download('$_filesDir/$name');

  @override
  Future<void> removeFiles(List<String> names) async {
    for (var i = 0; i < names.length; i += _pageSize) {
      final chunk = names.skip(i).take(_pageSize).map((n) => '$_filesDir/$n');
      await _bucket.remove(chunk.toList());
    }
  }

  @override
  Future<String?> downloadManifest() async {
    try {
      return utf8.decode(await _bucket.download(_manifestPath));
    } on StorageException catch (e) {
      // Older storage versions answer a missing object with 400 "Object not
      // found" rather than 404.
      if (e.statusCode == '404' || e.message.toLowerCase().contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> uploadManifest(String json) async {
    await _bucket.uploadBinary(
      _manifestPath,
      Uint8List.fromList(utf8.encode(json)),
      fileOptions: const FileOptions(
        contentType: 'application/json',
        upsert: true,
        cacheControl: '0',
      ),
    );
  }

  @override
  Future<void> removeManifest() => _bucket.remove([_manifestPath]);
}
