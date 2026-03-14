import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_service.dart';
import 'device_service.dart';
import 'event_service.dart';
import 'rate_limiter.dart';

class TicketService {
  final _firebase = FirebaseService();
  final _device = DeviceService();
  final _event = EventService();
  final _rateLimiter = RateLimiter();

  Future<Map<String, dynamic>?> createReservation({required String eventId, required String userName, required String gender}) async {
    final deviceId = await _device.getDeviceId();
    if (!_rateLimiter.isAllowed(deviceId, 'booking')) throw Exception('Too many attempts.');
    
    final docId = '${deviceId}_$eventId';
    final event = await _event.getEventById(eventId) ?? (throw Exception('Event not found'));

    final limit = (gender == 'male' ? event['maleLimit'] : event['femaleLimit']) as int? ?? 0;
    final booked = (gender == 'male' ? event['maleBooked'] : event['femaleBooked']) as int? ?? 0;

    if (limit <= 0) throw Exception('No tickets for $gender');
    if (booked >= limit) throw Exception('Sold out for $gender');

    final tId = 'TICKET-${List.generate(12, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'[Random.secure().nextInt(62)]).join()}';

    final reservation = {
      'eventId': eventId, 'deviceId': deviceId, 'userName': userName, 'gender': gender,
      'ticketId': tId, 'timestamp': DateTime.now().toIso8601String(),
      'isCancelled': false, 'isScanned': false, 'isDeleted': false,
      'checkedInAt': null, 'deletedAt': null, 'eventTitle_en': event['title_en'] ?? '',
      'eventTitle_ja': event['title_ja'] ?? '', 'eventDate': event['date'] ?? '',
      'eventTime': event['startTime'] ?? '', 'eventImage': (event['images_en'] as List?)?.firstOrNull,
    };

    final docRef = _firebase.reservationsCollection.doc(docId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final existing = await tx.get(docRef);
      if (existing.exists && (existing.data() as Map?)?['isCancelled'] == false) throw Exception('Already have a ticket');
      tx.set(docRef, reservation);
    });

    await _event.incrementBookedCount(eventId, gender);
    return {...reservation, 'id': docId, 'timestamp': DateTime.now().toIso8601String()};
  }

  Future<bool> hasExistingReservation(String dId, String eId) async =>
      ((await _firebase.reservationsCollection.doc('${dId}_$eId').get()).data() as Map?)?['isCancelled'] == false;

  List<Map<String, dynamic>> _mapDocs(QuerySnapshot s) => 
      s.docs.map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id}).toList();

  Stream<List<Map<String, dynamic>>> getMyReservations() => Stream.fromFuture(_device.getDeviceId()).asyncExpand((dId) =>
      _firebase.reservationsCollection.where('deviceId', isEqualTo: dId).where('isCancelled', isEqualTo: false).orderBy('timestamp', descending: true).snapshots().map(_mapDocs));

  Stream<List<Map<String, dynamic>>> getReservationsByEvent(String eId) =>
      _firebase.reservationsCollection.where('eventId', isEqualTo: eId).where('isCancelled', isEqualTo: false).orderBy('timestamp', descending: true).snapshots().map(_mapDocs);

  Stream<List<Map<String, dynamic>>> getLatestBookings({int limit = 3}) =>
      _firebase.reservationsCollection.where('isCancelled', isEqualTo: false).orderBy('timestamp', descending: true).limit(limit).snapshots().map(_mapDocs);

  Future<void> cancelReservation(String resId, String eventId, String gender) async {
    await _firebase.reservationsCollection.doc(resId).update({'isCancelled': true, 'cancelledAt': FieldValue.serverTimestamp()});
    final eventRef = _firebase.eventsCollection.doc(eventId);
    final field = gender == 'male' ? 'maleBooked' : 'femaleBooked';
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final current = ((await tx.get(eventRef)).data() as Map?)?[field] as int? ?? 0;
      if (current > 0) tx.update(eventRef, {field: current - 1});
    });
  }
}
