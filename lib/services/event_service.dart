import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class EventService {
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

  Future<String> createEvent(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser!;
    data.addAll({
      'createdBy': user.uid,
      'createdByEmail': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'maleBooked': 0,
      'femaleBooked': 0,
      'isHidden': false,
    });
    final doc = await _firebase.eventsCollection.add(data);
    await _notification.sendNewEventNotification(
        data['title_en'], data['description_en']);
    return doc.id;
  }

  Future<void> updateEvent(String id, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firebase.eventsCollection.doc(id).update(updates);
  }

  Future<void> deleteEvent(String id) async {
    // First delete all reservations/tickets for this event (including scanned ones)
    final reservationsSnap = await FirebaseFirestore.instance
        .collection('reservations')
        .where('eventId', isEqualTo: id)
        .get();

    for (final doc in reservationsSnap.docs) {
      await doc.reference.delete();
    }

    // Then delete the event itself
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
