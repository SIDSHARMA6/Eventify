import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final firestore = FirebaseFirestore.instance;
  // auth field removed — callers use FirebaseAuth.instance directly
  final messaging = FirebaseMessaging.instance;

  CollectionReference get eventsCollection => firestore.collection('events');
  CollectionReference get reservationsCollection =>
      firestore.collection('reservations');
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get locationsCollection =>
      firestore.collection('locations');
  CollectionReference get fcmTokensCollection =>
      firestore.collection('fcm_tokens');

  Future<void> initialize() async => firestore.settings =
      const Settings(persistenceEnabled: true, cacheSizeBytes: 104857600);
}
