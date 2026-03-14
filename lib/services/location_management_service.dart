import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class LocationManagementService {
  final _firebase = FirebaseService();

  Stream<List<Map<String, dynamic>>> getAllLocations() =>
      _firebase.locationsCollection.orderBy('order').snapshots().map((s) => s
          .docs
          .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
          .toList());

  Future<Map<String, dynamic>?> getLocationById(String id) async {
    final doc = await _firebase.locationsCollection.doc(id).get();
    return doc.exists
        ? {...doc.data() as Map<String, dynamic>, 'id': doc.id}
        : null;
  }

  Future<String> createLocation(Map<String, dynamic> data) async {
    data['createdAt'] = data['updatedAt'] = FieldValue.serverTimestamp();
    return (await _firebase.locationsCollection.add(data)).id;
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firebase.locationsCollection.doc(id).update(updates);
  }

  Future<void> deleteLocation(String id) async =>
      await _firebase.locationsCollection.doc(id).delete();

  Future<int> getLocationCount() async =>
      (await _firebase.locationsCollection.get()).docs.length;
}
