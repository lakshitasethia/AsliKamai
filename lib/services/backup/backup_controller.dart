import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/database.dart';
import '../../models/platform.dart';
import '../../models/rider_profile.dart';
import '../wipe_local_data.dart';
import 'backup_manifest.dart';
import 'backup_remote.dart';
import 'backup_service.dart';

/// Why the last backup/restore attempt didn't work, for the Backup screen
/// to explain in the rider's language.
enum BackupProblem { network, needsAppUpdate, damagedBackup, signedOut, other }

/// App-wide state for the optional cloud backup (build_execution.md
/// Phase 9): who's signed in, the rider's backup settings, and automatic
/// backups after changes. The actual copying is [BackupService].
///
/// Safety rule: a phone only backs up automatically once it is *linked* to
/// the signed-in account — by restoring, or by the rider choosing to
/// replace the cloud copy. Otherwise signing in on a new, empty phone would
/// immediately upload an empty backup over the rider's real one.
class BackupController extends ChangeNotifier {
  BackupController._();
  static final instance = BackupController._();

  static const _enabledKey = 'backup_enabled';
  static const _earningsKey = 'backup_include_earnings';
  static const _linkedKey = 'backup_linked_user';
  static const _lastAtKey = 'backup_last_at';

  /// Delay after the last change before an automatic backup, so a burst of
  /// imports becomes one backup.
  static Duration autoBackupDelay = const Duration(seconds: 30);

  SupabaseClient? _client;
  StreamSubscription<Object?>? _dbChanges;
  StreamSubscription<AuthState>? _authChanges;
  Timer? _debounce;
  bool _initialized = false;

  bool enabled = false;
  bool includeEarnings = false;
  String? _linkedUserId;
  DateTime? lastBackupAt;
  BackupProblem? problem;
  bool busy = false;
  bool _backupAgain = false;

  /// A backup already in the cloud, found when this phone signed in and
  /// isn't linked yet: the rider must choose restore or replace.
  BackupManifest? cloudBackupAwaitingDecision;

  /// Set when the cloud backup exists but this build can't read it.
  BackupProblem? cloudBackupUnreadable;

  /// False when the build has no Supabase config — backup is hidden then.
  bool get available => _client != null;

  bool get googleConfigured => (dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID') ?? '').isNotEmpty;

  User? get user => _client?.auth.currentUser;
  bool get signedIn => user != null;
  bool get linked => signedIn && _linkedUserId == user!.id;
  bool get awaitingDecision => signedIn && !linked;

  BackupService get _service => BackupService(
        db: AppDatabase.instance,
        docsDir: getApplicationDocumentsDirectory,
        loadProfile: () async {
          final profile = await RiderProfile.load();
          return BackupProfile(
            name: profile.name,
            platforms: profile.platforms.map((p) => p.name).toList(),
          );
        },
        saveProfile: ({String? name, List<String>? platforms}) async {
          if (name != null) await RiderProfile.saveName(name);
          if (platforms != null) {
            await RiderProfile.savePlatforms(platforms.map(GigPlatform.fromKey).toList());
          }
        },
      );

  BackupRemote get _remote => SupabaseBackupRemote(_client!, user!.id);

  /// Call once at startup, after Supabase.initialize (skipped when the
  /// build has no Supabase config, leaving [available] false).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null; // not initialised: no backup in this build
    }
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool(_enabledKey) ?? false;
    includeEarnings = prefs.getBool(_earningsKey) ?? false;
    _linkedUserId = prefs.getString(_linkedKey);
    final last = prefs.getString(_lastAtKey);
    lastBackupAt = last == null ? null : DateTime.tryParse(last);
    if (_client == null) return;

    _dbChanges = AppDatabase.instance.tableUpdates().listen((_) => scheduleBackup());
    _authChanges = _client!.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedOut) notifyListeners();
    });
    notifyListeners();
    // Catch up on anything changed while the app was closed or offline.
    if (enabled && linked) unawaited(backupNow());
  }

  /// Schedules an automatic backup [autoBackupDelay] after the last change.
  /// No-op unless backup is on and this phone is linked.
  void scheduleBackup() {
    if (!enabled || !linked) return;
    _debounce?.cancel();
    _debounce = Timer(autoBackupDelay, () => unawaited(backupNow()));
  }

  /// Returns false if the rider cancelled the Google account picker.
  Future<bool> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    await google.initialize(serverClientId: dotenv.get('GOOGLE_WEB_CLIENT_ID'));
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) throw StateError('Google returned no ID token');
    await _client!.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
    await checkCloud();
    return true;
  }

  /// Test-only sign-in for the on-device backup tests (Google sign-in can't
  /// be automated). Email accounts can't be created from the app.
  @visibleForTesting
  Future<void> signInWithPasswordForTest(String email, String password) async {
    await _client!.auth.signInWithPassword(email: email, password: password);
    await checkCloud();
  }

  /// After sign-in (and from "Try again"): link straight away if the cloud
  /// is empty, otherwise hold for the rider's restore/replace decision.
  Future<void> checkCloud() async {
    cloudBackupAwaitingDecision = null;
    cloudBackupUnreadable = null;
    problem = null;
    notifyListeners();
    await _setEnabled(true);
    if (linked) {
      await backupNow();
      return;
    }
    try {
      final existing = await _service.peek(_remote);
      if (existing == null) {
        // Nothing in the cloud to protect: link straight away.
        await _link();
        await backupNow();
      } else if (await _phoneIsEmpty()) {
        // Nothing here to lose (e.g. just switched accounts): bring this
        // account's data back without asking.
        cloudBackupAwaitingDecision = existing;
        notifyListeners();
        await restoreAndLink();
        return;
      } else {
        cloudBackupAwaitingDecision = existing;
      }
    } on UnsupportedBackupVersion {
      cloudBackupUnreadable = BackupProblem.needsAppUpdate;
    } on FormatException {
      cloudBackupUnreadable = BackupProblem.damagedBackup;
    } catch (e) {
      problem = _classify(e);
      debugPrint('AsliKamai: cloud check failed: $e');
    }
    notifyListeners();
  }

  /// Merge the cloud backup into this phone, then link it (and back up the
  /// merged result so the cloud also has anything that was only here).
  Future<RestoreReport?> restoreAndLink() async {
    if (!signedIn || busy) return null;
    busy = true;
    problem = null;
    notifyListeners();
    try {
      final report = await _service.restore(_remote);
      if (report.backupIncludedEarnings && !includeEarnings) {
        // Carry the rider's choice over from the old phone; otherwise the
        // next backup would remove their orders & expenses from the cloud.
        includeEarnings = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_earningsKey, true);
      }
      await _link();
      cloudBackupAwaitingDecision = null;
      busy = false;
      await backupNow();
      return report;
    } on NoBackupFound {
      await _link();
      cloudBackupAwaitingDecision = null;
      busy = false;
      await backupNow();
      return null;
    } catch (e, st) {
      problem = _classify(e);
      debugPrint('AsliKamai: restore failed: $e\n$st');
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Rider chose to replace the cloud copy with this phone's data.
  Future<void> replaceCloudAndLink() async {
    if (!signedIn) return;
    if (cloudBackupUnreadable == BackupProblem.needsAppUpdate) return;
    await _link();
    cloudBackupAwaitingDecision = null;
    cloudBackupUnreadable = null;
    await backupNow();
  }

  /// Backs up now. Safe to call any time: does nothing unless signed in,
  /// enabled and linked; if a backup is already running, runs once more
  /// after it so the latest changes are included.
  Future<BackupReport?> backupNow() async {
    if (!enabled || !linked) return null;
    if (busy) {
      _backupAgain = true;
      return null;
    }
    _debounce?.cancel();
    busy = true;
    notifyListeners();
    BackupReport? report;
    try {
      do {
        _backupAgain = false;
        report = await _service.backup(_remote, includeEarnings: includeEarnings);
      } while (_backupAgain && enabled && linked);
      problem = null;
      lastBackupAt = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastAtKey, lastBackupAt!.toIso8601String());
    } catch (e) {
      problem = _classify(e);
      debugPrint('AsliKamai: backup failed: $e');
    } finally {
      busy = false;
      notifyListeners();
    }
    return report;
  }

  Future<void> setIncludeEarnings(bool value) async {
    includeEarnings = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_earningsKey, value);
    notifyListeners();
    await backupNow();
  }

  /// Turning backup off stops syncing at once; [deleteCloudCopy] also
  /// removes what's already in the cloud.
  Future<void> turnOff({required bool deleteCloudCopy}) async {
    _debounce?.cancel();
    await _setEnabled(false);
    if (deleteCloudCopy && signedIn) {
      try {
        await _service.deleteCloudCopy(_remote);
        lastBackupAt = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_lastAtKey);
      } catch (e) {
        problem = _classify(e);
        notifyListeners();
        rethrow;
      }
    }
    notifyListeners();
  }

  Future<void> turnOn() async {
    await _setEnabled(true);
    await backupNow();
  }

  /// Sign out so another account can use this phone: back up one last
  /// time, then clear this account's data off the phone — it comes back
  /// when the account signs in again. Returns false (and sets [problem])
  /// if the final backup failed; nothing is cleared then. A phone that was
  /// never linked (restore/replace not chosen yet) just signs out.
  Future<bool> signOutAndClearPhone() async {
    final wasLinked = linked;
    if (wasLinked && enabled) {
      while (busy) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      await backupNow();
      if (problem != null) return false;
    }
    await signOut();
    if (wasLinked) await wipeAllLocalData();
    return true;
  }

  Future<bool> _phoneIsEmpty() async {
    final db = AppDatabase.instance;
    return (await db.allOrders()).isEmpty &&
        (await db.allExpenses()).isEmpty &&
        (await db.allEvidence()).isEmpty &&
        (await db.allLetters()).isEmpty;
  }

  Future<void> signOut() async {
    _debounce?.cancel();
    await _unlinkLocally();
    try {
      await _client?.auth.signOut();
    } catch (_) {
      // Offline: the local session is cleared regardless.
    }
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    notifyListeners();
  }

  /// "Delete everything" in the cloud: backup files and the account itself.
  /// Throws if it couldn't (e.g. offline) — the caller decides whether to
  /// still wipe the phone.
  Future<void> deleteAccount() async {
    if (!signedIn) return;
    _debounce?.cancel();
    final response = await _client!.functions.invoke('delete-account');
    if (response.status != 200) {
      throw HttpException('delete-account returned ${response.status}');
    }
    await signOut();
    await _setEnabled(false);
  }

  /// Stop all syncing from this phone without touching the cloud — used
  /// before "delete from this phone only", so wiping the phone can't be
  /// auto-backed-up as an empty backup over the cloud copy.
  Future<void> detachFromCloud() => signOut();

  Future<void> _link() async {
    _linkedUserId = user!.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_linkedKey, _linkedUserId!);
  }

  Future<void> _unlinkLocally() async {
    _linkedUserId = null;
    cloudBackupAwaitingDecision = null;
    cloudBackupUnreadable = null;
    problem = null;
    lastBackupAt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_linkedKey);
    await prefs.remove(_lastAtKey);
  }

  Future<void> _setEnabled(bool value) async {
    enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  BackupProblem _classify(Object e) {
    if (e is UnsupportedBackupVersion) return BackupProblem.needsAppUpdate;
    if (e is FormatException) return BackupProblem.damagedBackup;
    if (e is AuthException) return BackupProblem.signedOut;
    if (e is SocketException || e is TimeoutException || e is HttpException) {
      return BackupProblem.network;
    }
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup')) {
      return BackupProblem.network;
    }
    if (e is StorageException && (e.statusCode == '401' || e.statusCode == '403')) {
      return BackupProblem.signedOut;
    }
    return BackupProblem.other;
  }

  @visibleForTesting
  Future<void> resetForTest() async {
    _debounce?.cancel();
    await _dbChanges?.cancel();
    await _authChanges?.cancel();
    _dbChanges = null;
    _authChanges = null;
    _initialized = false;
    enabled = false;
    includeEarnings = false;
    _linkedUserId = null;
    lastBackupAt = null;
    problem = null;
    busy = false;
    cloudBackupAwaitingDecision = null;
    cloudBackupUnreadable = null;
  }
}
