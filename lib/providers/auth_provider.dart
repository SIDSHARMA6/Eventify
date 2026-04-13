import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId, _userEmail, _userRole;
  bool _isLoading = true; // true until _load() completes
  static const _timeout = Duration(hours: 24);

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != null;
  bool get isCreator => _userRole == 'creator';
  bool get isAdmin => _userRole == 'admin';

  AuthProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      final uid = prefs.getString('user_id');

      if (uid == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check session timeout
      final lastStr = prefs.getString('last_activity');
      if (lastStr != null) {
        final diff = DateTime.now().difference(DateTime.parse(lastStr));
        if (diff > _timeout) {
          await _clearSession(prefs);
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _userId = uid;
      _userEmail = prefs.getString('user_email');
      _userRole = prefs.getString('user_role');
      _isLoading = false;
      notifyListeners();

      // Background revalidation — doesn't block UI
      _revalidate(prefs);
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _revalidate(SharedPreferences prefs) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await _clearSession(prefs);
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      final role = doc.data()?['role'] as String?;
      if (!doc.exists || !['admin', 'creator'].contains(role)) {
        await _clearSession(prefs);
        return;
      }
      if (role != _userRole) {
        _userRole = role;
        await prefs.setString('user_role', _userRole!);
        notifyListeners();
      }
    } on FirebaseAuthException {
      // Auth token invalid — force logout
      await _clearSession(prefs);
    } catch (_) {
      // Network error — keep existing session, will revalidate next launch
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      final role = doc.data()?['role'] as String? ?? '';
      if (!['admin', 'creator'].contains(role)) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Unauthorized');
      }

      _userId = cred.user!.uid;
      _userEmail = email.trim();
      _userRole = role;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_email', _userEmail!);
      await prefs.setString('user_role', _userRole!);
      await prefs.setString('last_activity', DateTime.now().toIso8601String());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_activity', DateTime.now().toIso8601String());
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await Future.wait(['user_id', 'user_email', 'user_role', 'last_activity']
        .map((k) => prefs.remove(k)));
    _userId = _userEmail = _userRole = null;
    notifyListeners();
  }
}
