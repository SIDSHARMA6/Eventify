import 'firebase_service.dart';

class UserManagementService {
  Stream<List<Map<String, dynamic>>> getAllCreators() => FirebaseService()
      .usersCollection
      .where('role', isEqualTo: 'creator')
      .snapshots()
      .map((s) => s.docs
          .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
          .toList());
}
