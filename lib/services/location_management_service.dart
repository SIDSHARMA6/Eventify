import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class LocationManagementService {
  final FirebaseService _firebase = FirebaseService();

  // Get all locations
  Stream<List<Map<String, dynamic>>> getAllLocations() {
    return _firebase.locationsCollection
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get location by ID
  Future<Map<String, dynamic>?> getLocationById(String locationId) async {
    try {
      final doc = await _firebase.locationsCollection.doc(locationId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Get location error: $e');
      return null;
    }
  }

  // Create location (Admin only)
  Future<String?> createLocation(Map<String, dynamic> locationData) async {
    try {
      locationData['createdAt'] = FieldValue.serverTimestamp();
      locationData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firebase.locationsCollection.add(locationData);
      return docRef.id;
    } catch (e) {
      print('Create location error: $e');
      rethrow;
    }
  }

  // Update location (Admin only)
  Future<void> updateLocation(
      String locationId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firebase.locationsCollection.doc(locationId).update(updates);
    } catch (e) {
      print('Update location error: $e');
      rethrow;
    }
  }

  // Delete location (Admin only)
  Future<void> deleteLocation(String locationId) async {
    try {
      await _firebase.locationsCollection.doc(locationId).delete();
    } catch (e) {
      print('Delete location error: $e');
      rethrow;
    }
  }

  // Get location count
  Future<int> getLocationCount() async {
    try {
      final snapshot = await _firebase.locationsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Get location count error: $e');
      return 0;
    }
  }
}
