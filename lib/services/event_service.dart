import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class EventService {
  final FirebaseService _firebase = FirebaseService();
  final AuthService _auth = AuthService();
  final NotificationService _notification = NotificationService();

  // Get all non-hidden events
  Stream<List<Map<String, dynamic>>> getEvents() {
    return _firebase.eventsCollection
        .where('isHidden', isEqualTo: false)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get all events including hidden (Admin only)
  Stream<List<Map<String, dynamic>>> getAllEvents() {
    return _firebase.eventsCollection
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get events by location
  Stream<List<Map<String, dynamic>>> getEventsByLocation(String location) {
    if (location == 'All') {
      return getEvents();
    }

    return _firebase.eventsCollection
        .where('isHidden', isEqualTo: false)
        .where('location_en', isEqualTo: location)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get events by creator
  Stream<List<Map<String, dynamic>>> getEventsByCreator(String creatorId) {
    return _firebase.eventsCollection
        .where('createdBy', isEqualTo: creatorId)
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

  // Get single event by ID
  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      final doc = await _firebase.eventsCollection.doc(eventId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Get event error: $e');
      return null;
    }
  }

  // Create new event
  Future<String?> createEvent(Map<String, dynamic> eventData) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      eventData['createdBy'] = currentUser.uid;
      eventData['createdAt'] = FieldValue.serverTimestamp();
      eventData['updatedAt'] = FieldValue.serverTimestamp();
      eventData['maleBooked'] = 0;
      eventData['femaleBooked'] = 0;
      eventData['isHidden'] = false;

      final docRef = await _firebase.eventsCollection.add(eventData);

      // Send notification to all users
      await _notification.sendNewEventNotification(
        eventData['title_en'],
        eventData['description_en'],
      );

      return docRef.id;
    } catch (e) {
      print('Create event error: $e');
      rethrow;
    }
  }

  // Update event
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firebase.eventsCollection.doc(eventId).update(updates);
    } catch (e) {
      print('Update event error: $e');
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firebase.eventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Delete event error: $e');
      rethrow;
    }
  }

  // Hide/Show event
  Future<void> toggleEventVisibility(String eventId, bool isHidden) async {
    try {
      await _firebase.eventsCollection.doc(eventId).update({
        'isHidden': isHidden,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Toggle visibility error: $e');
      rethrow;
    }
  }

  // Duplicate event
  Future<String?> duplicateEvent(String eventId) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) return null;

      // Remove ID and update timestamps
      event.remove('id');
      event['createdAt'] = FieldValue.serverTimestamp();
      event['updatedAt'] = FieldValue.serverTimestamp();
      event['maleBooked'] = 0;
      event['femaleBooked'] = 0;

      final docRef = await _firebase.eventsCollection.add(event);
      return docRef.id;
    } catch (e) {
      print('Duplicate event error: $e');
      rethrow;
    }
  }

  // Increment booked count
  Future<void> incrementBookedCount(String eventId, String gender) async {
    try {
      final field = gender == 'male' ? 'maleBooked' : 'femaleBooked';
      await _firebase.eventsCollection.doc(eventId).update({
        field: FieldValue.increment(1),
      });
    } catch (e) {
      print('Increment booked count error: $e');
      rethrow;
    }
  }

  // Decrement booked count
  Future<void> decrementBookedCount(String eventId, String gender) async {
    try {
      final field = gender == 'male' ? 'maleBooked' : 'femaleBooked';
      await _firebase.eventsCollection.doc(eventId).update({
        field: FieldValue.increment(-1),
      });
    } catch (e) {
      print('Decrement booked count error: $e');
      rethrow;
    }
  }
}
