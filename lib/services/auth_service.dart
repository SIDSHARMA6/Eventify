import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebase = FirebaseService();

  // Get current user
  User? get currentUser => _firebase.auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();

  // Login with email and password
  Future<UserCredential?> login(String email, String password) async {
    try {
      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Register new user (Creator or Admin)
  Future<UserCredential?> register(
    String email,
    String password,
    String role,
  ) async {
    try {
      final credential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firebase.usersCollection.doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'email': email,
        'role': role, // 'creator' or 'admin'
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _firebase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firebase.usersCollection.doc(uid).get();
      if (doc.exists) {
        return doc.get('role') as String?;
      }
      return null;
    } catch (e) {
      print('Get user role error: $e');
      return null;
    }
  }

  // Check if user is creator
  Future<bool> isCreator() async {
    if (currentUser == null) return false;
    final role = await getUserRole(currentUser!.uid);
    return role == 'creator';
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final role = await getUserRole(currentUser!.uid);
    return role == 'admin';
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }
}
