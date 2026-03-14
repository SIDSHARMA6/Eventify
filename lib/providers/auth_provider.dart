import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _userEmail;
  String? _userRole;
  bool _isLoading = false;
  DateTime? _lastActivityTime;

  // Session timeout configuration
  static const Duration _sessionTimeout = Duration(minutes: 30); // Idle timeout
  static const Duration _maxSessionDuration =
      Duration(hours: 24); // Max session
  DateTime? _sessionStartTime;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoggedIn => _userId != null;
  bool get isLoading => _isLoading;
  bool get isCreator => _userRole == 'creator';
  bool get isAdmin => _userRole == 'admin';

  // Initialize: load from SharedPrefs instantly, then validate against Firestore
  AuthProvider() {
    _loadAndValidate();
  }

  /// Step 1 — restore from cache so UI is not blank on restart.
  /// Step 2 — immediately re-validate role against Firestore & Firebase Auth.
  ///           If account was deactivated/downgraded, we force logout.
  Future<void> _loadAndValidate() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return; // never logged in

    // Check session timeout
    final lastActivityStr = prefs.getString('last_activity');
    final sessionStartStr = prefs.getString('session_start');

    if (lastActivityStr != null && sessionStartStr != null) {
      final lastActivity = DateTime.parse(lastActivityStr);
      final sessionStart = DateTime.parse(sessionStartStr);
      final now = DateTime.now();

      // Check idle timeout (30 minutes)
      if (now.difference(lastActivity) > _sessionTimeout) {
        if (kDebugMode) {
          debugPrint('⚠️ AuthProvider: Session expired (idle timeout)');
        }
        await _clearSession(prefs);
        return;
      }

      // Check max session duration (24 hours)
      if (now.difference(sessionStart) > _maxSessionDuration) {
        if (kDebugMode) {
          debugPrint('⚠️ AuthProvider: Session expired (max duration)');
        }
        await _clearSession(prefs);
        return;
      }
    }

    // Optimistic restore (makes UI fast on restart)
    _userId = id;
    _userEmail = prefs.getString('user_email');
    _userRole = prefs.getString('user_role');
    _lastActivityTime = lastActivityStr != null
        ? DateTime.parse(lastActivityStr)
        : DateTime.now();
    _sessionStartTime =
        sessionStartStr != null ? DateTime.parse(sessionStartStr) : null;
    notifyListeners();

    // Update activity timestamp
    await _updateActivity();

    // Background validation against Firestore + Firebase Auth token
    _revalidateSession(id, prefs);
  }

  /// Update last activity timestamp
  Future<void> _updateActivity() async {
    _lastActivityTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_activity', _lastActivityTime!.toIso8601String());
  }

  /// Check if session is still valid (call this on important actions)
  Future<bool> checkSessionValidity() async {
    if (_userId == null) return false;

    final now = DateTime.now();

    // Check idle timeout
    if (_lastActivityTime != null &&
        now.difference(_lastActivityTime!) > _sessionTimeout) {
      if (kDebugMode) {
        debugPrint('⚠️ Session expired (idle)');
      }
      await logout();
      return false;
    }

    // Check max session duration
    if (_sessionStartTime != null &&
        now.difference(_sessionStartTime!) > _maxSessionDuration) {
      if (kDebugMode) {
        debugPrint('⚠️ Session expired (max duration)');
      }
      await logout();
      return false;
    }

    // Update activity
    await _updateActivity();
    return true;
  }

  Future<void> _revalidateSession(String uid, SharedPreferences prefs) async {
    try {
      // 1. Check Firebase Auth still has a valid session
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null || firebaseUser.uid != uid) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ AuthProvider: Firebase session expired — forcing logout');
        }
        await _clearSession(prefs);
        return;
      }

      // 2. Force token refresh to ensure it isn't revoked
      await firebaseUser.getIdToken(true);

      // 3. Re-read role from Firestore (catches deactivated / downgraded accounts)
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          debugPrint('⚠️ AuthProvider: User doc missing — forcing logout');
        }
        await _clearSession(prefs);
        return;
      }

      final liveRole = userDoc.data()!['role'] as String? ?? '';
      if (liveRole != 'admin' && liveRole != 'creator') {
        if (kDebugMode) {
          debugPrint('⚠️ AuthProvider: Role not authorised — forcing logout');
        }
        await _clearSession(prefs);
        return;
      }

      // 4. If role changed (e.g. creator promoted to admin), update local state
      if (liveRole != _userRole) {
        _userRole = liveRole;
        await prefs.setString('user_role', liveRole);
        notifyListeners();
        if (kDebugMode) {
          debugPrint('ℹ️ AuthProvider: Role updated');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ AuthProvider: Session validated');
      }
    } catch (e) {
      // Network error — keep cached session, don't force logout on no-network
      if (kDebugMode) {
        debugPrint('⚠️ AuthProvider: Validation error (keeping cache): $e');
      }
    }
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await FirebaseAuth.instance.signOut();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('last_activity');
    await prefs.remove('session_start');
    _userId = null;
    _userEmail = null;
    _userRole = null;
    _lastActivityTime = null;
    _sessionStartTime = null;
    notifyListeners();
  }

  // Login with Firebase Auth + Firestore role lookup
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password:
            password, // M-4: do NOT trim — passwords may intentionally have spaces
      );

      final uid = credential.user!.uid;

      // Force fresh token
      await credential.user!.getIdToken(true);

      // Read role from Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('User account not found. Contact admin.');
      }

      final role = userDoc.data()!['role'] as String? ?? '';
      if (role != 'admin' && role != 'creator') {
        await FirebaseAuth.instance.signOut();
        throw Exception(
            'Unauthorized: your account does not have admin or creator access.');
      }

      _userId = uid;
      _userEmail = email.trim();
      _userRole = role;
      _sessionStartTime = DateTime.now();
      _lastActivityTime = DateTime.now();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', uid);
      await prefs.setString('user_email', email.trim());
      await prefs.setString('user_role', role);
      await prefs.setString(
          'session_start', _sessionStartTime!.toIso8601String());
      await prefs.setString(
          'last_activity', _lastActivityTime!.toIso8601String());

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      final msg = e.code == 'user-not-found'
          ? 'No account found for that email.'
          : e.code == 'wrong-password'
              ? 'Incorrect password.'
              : e.code == 'invalid-credential'
                  ? 'Invalid email or password.'
                  : e.message ?? 'Login failed.';
      throw Exception(msg);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout — clears all state
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearSession(prefs);
    } catch (e) {
      rethrow;
    }
  }
}
