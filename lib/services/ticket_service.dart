import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_service.dart';
import 'device_service.dart';
import 'event_service.dart';

class TicketService {
  final FirebaseService _firebase = FirebaseService();
  final DeviceService _device = DeviceService();
  final EventService _event = EventService();

  // Create reservation
  Future<Map<String, dynamic>?> createReservation({
    required String eventId,
    required String userName,
    required String gender,
  }) async {
    try {
      final deviceId = await _device.getDeviceId();

      // Check if already booked
      final existing = await hasExistingReservation(deviceId, eventId);
      if (existing) {
        throw Exception('You already have a ticket for this event');
      }

      // Check gender limit
      final event = await _event.getEventById(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final limit =
          gender == 'male' ? event['maleLimit'] : event['femaleLimit'];
      final booked =
          gender == 'male' ? event['maleBooked'] : event['femaleBooked'];

      if (booked >= limit) {
        throw Exception('Sorry, this event is sold out for $gender');
      }

      // Generate ticket ID
      final ticketId =
          'TICKET-${Random().nextInt(999999).toString().padLeft(6, '0')}';

      // Create reservation
      final reservation = {
        'eventId': eventId,
        'deviceId': deviceId,
        'userName': userName,
        'gender': gender,
        'ticketId': ticketId,
        'timestamp': FieldValue.serverTimestamp(),
        'isCancelled': false,
      };

      final docRef = await _firebase.reservationsCollection.add(reservation);

      // Increment booked count
      await _event.incrementBookedCount(eventId, gender);

      // Return reservation with ID
      reservation['id'] = docRef.id;
      reservation['timestamp'] = DateTime.now().toIso8601String();

      return reservation;
    } catch (e) {
      print('Create reservation error: $e');
      rethrow;
    }
  }

  // Check if device already has reservation for event
  Future<bool> hasExistingReservation(String deviceId, String eventId) async {
    try {
      final snapshot = await _firebase.reservationsCollection
          .where('deviceId', isEqualTo: deviceId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Check existing reservation error: $e');
      return false;
    }
  }

  // Get reservations by device
  Stream<List<Map<String, dynamic>>> getMyReservations() {
    return Stream.fromFuture(_device.getDeviceId()).asyncExpand((deviceId) {
      return _firebase.reservationsCollection
          .where('deviceId', isEqualTo: deviceId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  // Get reservations by event (for creator/admin)
  Stream<List<Map<String, dynamic>>> getReservationsByEvent(String eventId) {
    return _firebase.reservationsCollection
        .where('eventId', isEqualTo: eventId)
        .where('isCancelled', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get latest bookings (for home screen)
  Stream<List<Map<String, dynamic>>> getLatestBookings({int limit = 3}) {
    return _firebase.reservationsCollection
        .where('isCancelled', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Cancel reservation
  Future<void> cancelReservation(
      String reservationId, String eventId, String gender) async {
    try {
      await _firebase.reservationsCollection.doc(reservationId).update({
        'isCancelled': true,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Decrement booked count
      await _event.decrementBookedCount(eventId, gender);
    } catch (e) {
      print('Cancel reservation error: $e');
      rethrow;
    }
  }

  // Get reservation statistics for event
  Future<Map<String, dynamic>> getEventStats(String eventId) async {
    try {
      final snapshot = await _firebase.reservationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .get();

      int maleCount = 0;
      int femaleCount = 0;

      for (var doc in snapshot.docs) {
        final gender = doc.get('gender') as String;
        if (gender == 'male') {
          maleCount++;
        } else {
          femaleCount++;
        }
      }

      return {
        'totalBookings': snapshot.docs.length,
        'maleBookings': maleCount,
        'femaleBookings': femaleCount,
      };
    } catch (e) {
      print('Get event stats error: $e');
      return {
        'totalBookings': 0,
        'maleBookings': 0,
        'femaleBookings': 0,
      };
    }
  }
}
