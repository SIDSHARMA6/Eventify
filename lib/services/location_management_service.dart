import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class LocationManagementService {
  static final LocationManagementService _instance =
      LocationManagementService._internal();
  factory LocationManagementService() => _instance;
  LocationManagementService._internal();

  final _firebase = FirebaseService();

  // Cached last value — new subscribers get data instantly, no spinner
  List<Map<String, dynamic>>? _locationsCache;

  late final Stream<List<Map<String, dynamic>>> _locationsStream =
      _firebase.locationsCollection.orderBy('order').snapshots().map((s) {
    final result = s.docs
        .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
        .toList();
    _locationsCache = result;
    return result;
  }).asBroadcastStream();

  Stream<List<Map<String, dynamic>>> getAllLocations() async* {
    if (_locationsCache != null) yield _locationsCache!;
    yield* _locationsStream;
  }

  Future<String> createLocation(Map<String, dynamic> data) async {
    final payload = <String, dynamic>{
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return (await _firebase.locationsCollection.add(payload)).id;
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    final payload = <String, dynamic>{
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firebase.locationsCollection.doc(id).update(payload);
  }

  Future<void> deleteLocation(String id) async =>
      await _firebase.locationsCollection.doc(id).delete();
}
