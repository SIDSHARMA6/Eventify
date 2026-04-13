import 'firebase_service.dart';

class UserManagementService {
  static final UserManagementService _instance =
      UserManagementService._internal();
  factory UserManagementService() => _instance;
  UserManagementService._internal();

  final _firebase = FirebaseService();

  List<Map<String, dynamic>>? _creatorsCache;

  late final Stream<List<Map<String, dynamic>>> _creatorsStream = _firebase
      .usersCollection
      .where('role', isEqualTo: 'creator')
      .snapshots()
      .map((s) {
    final result = s.docs
        .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
        .toList();
    _creatorsCache = result;
    return result;
  }).asBroadcastStream();

  Stream<List<Map<String, dynamic>>> getAllCreators() async* {
    if (_creatorsCache != null) yield _creatorsCache!;
    yield* _creatorsStream;
  }

  Future<void> deleteCreator(String id) =>
      _firebase.usersCollection.doc(id).delete();
}
