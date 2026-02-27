import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class UserManagementService {
  final FirebaseService _firebase = FirebaseService();

  // Get all users (Admin only)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firebase.usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get users by role
  Stream<List<Map<String, dynamic>>> getUsersByRole(String role) {
    return _firebase.usersCollection
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get all creators
  Stream<List<Map<String, dynamic>>> getAllCreators() {
    return getUsersByRole('creator');
  }

  // Get all admins
  Stream<List<Map<String, dynamic>>> getAllAdmins() {
    return getUsersByRole('admin');
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firebase.usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Create new user (Admin only)
  Future<String> createUser(String email, String password, String role) async {
    try {
      final docRef = await _firebase.usersCollection.add({
        'email': email,
        'password': password, // In production, this should be hashed
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  // Reset user password (Admin only)
  Future<void> resetPassword(String userId, String newPassword) async {
    try {
      await _firebase.usersCollection.doc(userId).update({
        'password': newPassword, // In production, this should be hashed
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firebase.usersCollection.doc(userId).update(updates);
    } catch (e) {
      print('Update user error: $e');
      rethrow;
    }
  }

  // Delete user (Admin only)
  Future<void> deleteUser(String userId) async {
    try {
      await _firebase.usersCollection.doc(userId).delete();
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      final snapshot = await _firebase.usersCollection.get();

      int totalUsers = snapshot.docs.length;
      int creators = 0;
      int admins = 0;

      for (var doc in snapshot.docs) {
        final role = doc.get('role') as String?;
        if (role == 'creator') {
          creators++;
        } else if (role == 'admin') {
          admins++;
        }
      }

      return {
        'total': totalUsers,
        'creators': creators,
        'admins': admins,
      };
    } catch (e) {
      print('Get user stats error: $e');
      return {
        'total': 0,
        'creators': 0,
        'admins': 0,
      };
    }
  }
}
