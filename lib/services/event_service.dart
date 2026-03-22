import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final _firebase = FirebaseService();
  final _notification = NotificationService();

  List<Map<String, dynamic>> _mapDocs(QuerySnapshot s) => s.docs
      .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
      .toList();

  Stream<List<Map<String, dynamic>>> getEvents() => _firebase.eventsCollection
      .where('isHidden', isEqualTo: false)
      .orderBy('date')
      .snapshots()
      .map(_mapDocs);

  Stream<List<Map<String, dynamic>>> getAllEvents() =>
      _firebase.eventsCollection.orderBy('date').snapshots().map(_mapDocs);

  Stream<List<Map<String, dynamic>>> getEventsByLocation(
          String loc) =>
      loc == 'All'
          ? getEvents()
          : _firebase.eventsCollection
              .where('isHidden', isEqualTo: false)
              .where('location_en', isEqualTo: loc)
              .orderBy('date')
              .snapshots()
              .map(_mapDocs);

  Stream<List<Map<String, dynamic>>> getEventsByCreator(String id) =>
      _firebase.eventsCollection
          .where('createdBy', isEqualTo: id)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(_mapDocs);

  Future<Map<String, dynamic>?> getEventById(String id) async {
    final doc = await _firebase.eventsCollection.doc(id).get();
    return doc.exists
        ? {...doc.data() as Map<String, dynamic>, 'id': doc.id}
        : null;
  }

  Stream<Map<String, dynamic>?> watchEvent(String id) =>
      _firebase.eventsCollection.doc(id).snapshots().map((doc) => doc.exists
          ? {...doc.data() as Map<String, dynamic>, 'id': doc.id}
          : null);

  Future<String> createEvent(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser!;
    final payload = <String, dynamic>{
      ...data,
      'createdBy': user.uid,
      'createdByEmail': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'maleBooked': data['maleBooked'] ?? 0,
      'femaleBooked': data['femaleBooked'] ?? 0,
      'isHidden': data['isHidden'] ?? false,
    };
    final doc = await _firebase.eventsCollection.add(payload);
    await _notification.sendNewEventNotification(
        data['title_en'], data['description_en']);
    return doc.id;
  }

  Future<void> updateEvent(String id, Map<String, dynamic> updates) async {
    final payload = <String, dynamic>{
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firebase.eventsCollection.doc(id).update(payload);
  }

  Future<void> deleteEvent(String id) async {
    final reservationsSnap = await _firebase.reservationsCollection
        .where('eventId', isEqualTo: id)
        .get();
    for (final doc in reservationsSnap.docs) {
      await doc.reference.delete();
    }
    await _firebase.eventsCollection.doc(id).delete();
  }

  Future<void> toggleEventVisibility(String id, bool hidden) async =>
      await _firebase.eventsCollection.doc(id).update(
          {'isHidden': hidden, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> incrementBookedCount(String id, String gender) async =>
      await _firebase.eventsCollection.doc(id).update({
        gender == 'male' ? 'maleBooked' : 'femaleBooked':
            FieldValue.increment(1)
      });
}
