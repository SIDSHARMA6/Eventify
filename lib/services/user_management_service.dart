import 'firebase_service.dart';

class UserManagementService {
  static final UserManagementService _instance =
      UserManagementService._internal();
  factory UserManagementService() => _instance;
  UserManagementService._internal();

  final _firebase = FirebaseService();

  Stream<List<Map<String, dynamic>>> getAllCreators() =>
      _firebase.usersCollection
          .where('role', isEqualTo: 'creator')
          .snapshots()
          .map((s) => s.docs
              .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
              .toList());

  Future<void> deleteCreator(String id) =>
      _firebase.usersCollection.doc(id).delete();

  Stream<int> getLocationsCount() =>
      _firebase.locationsCollection.snapshots().map((s) => s.docs.length);
}
