import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _userRole;
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  // Initialize and listen to auth state
  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _userRole = await _authService.getUserRole(user.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _authService.login(email, password);
      if (credential != null) {
        _user = credential.user;
        _userRole = await _authService.getUserRole(_user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Register
  Future<bool> register(String email, String password, String role) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _authService.register(email, password, role);
      if (credential != null) {
        _user = credential.user;
        _userRole = role;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _userRole = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is creator
  bool get isCreator => _userRole == 'creator';

  // Check if user is admin
  bool get isAdmin => _userRole == 'admin';
}
