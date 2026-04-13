import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_service.dart';
import 'device_service.dart';
import 'rate_limiter.dart';
import 'notification_service.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final _firebase = FirebaseService();
  final _device = DeviceService();
  final _rateLimiter = RateLimiter();
  final _notifications = NotificationService();

  List<Map<String, dynamic>> _mapDocs(QuerySnapshot s) => s.docs
      .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
      .toList();

  Future<Map<String, dynamic>?> createReservation({
    required String eventId,
    required String userName,
    required String gender,
  }) async {
    final deviceId = await _device.getDeviceId();
    if (!await _rateLimiter.isAllowed(deviceId, 'booking')) {
      throw Exception('Too many attempts.');
    }

    final tId =
        'TICKET-${List.generate(12, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'[Random.secure().nextInt(62)]).join()}';

    final docId = '${deviceId}_$eventId';
    final docRef = _firebase.reservationsCollection.doc(docId);
    final eventRef = _firebase.eventsCollection.doc(eventId);
    final limitField = gender == 'male' ? 'maleLimit' : 'femaleLimit';
    final bookedField = gender == 'male' ? 'maleBooked' : 'femaleBooked';

    late Map<String, dynamic> reservation;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final eventSnap = await tx.get(eventRef);
      if (!eventSnap.exists) throw Exception('Event not found');

      final data = eventSnap.data() as Map<String, dynamic>;
      if (data['isHidden'] == true) throw Exception('event_hidden');

      final limit = (data[limitField] as int?) ?? 0;
      final booked = (data[bookedField] as int?) ?? 0;

      if (limit <= 0) throw Exception('No tickets for $gender');
      if (booked >= limit) throw Exception('Sold out for $gender');

      final existing = await tx.get(docRef);
      if (existing.exists) throw Exception('Already have a ticket');

      reservation = {
        'eventId': eventId,
        'deviceId': deviceId,
        'userName': userName,
        'gender': gender,
        'ticketId': tId,
        'timestamp': DateTime.now().toIso8601String(),
        'isScanned': false,
        'checkedInAt': null,
        'eventTitle_en': data['title_en'] ?? '',
        'eventTitle_ja': data['title_ja'] ?? '',
        'eventDate': data['date'] ?? '',
        'eventTime': data['startTime'] ?? '',
        'eventImage': (data['images_en'] as List?)?.firstOrNull,
      };

      tx.set(docRef, reservation);
      tx.update(eventRef, {bookedField: FieldValue.increment(1)});
    });

    await _notifications.sendTicketConfirmation(
      eventTitle: reservation['eventTitle_en'] as String? ?? '',
      ticketId: tId,
    );

    return {...reservation, 'id': docId};
  }

  // Hard-delete model: ticket exists = active
  Future<bool> hasExistingReservation(String dId, String eId) async {
    final doc = await _firebase.reservationsCollection.doc('${dId}_$eId').get();
    return doc.exists;
  }

  Stream<bool> watchReservation(String dId, String eId) =>
      _firebase.reservationsCollection
          .doc('${dId}_$eId')
          .snapshots()
          .map((snap) => snap.exists);

  Stream<List<Map<String, dynamic>>> getMyReservations() async* {
    final dId = await _device.getDeviceId();
    yield* _firebase.reservationsCollection
        .where('deviceId', isEqualTo: dId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  Stream<List<Map<String, dynamic>>> getReservationsByEvent(String eId) =>
      _firebase.reservationsCollection
          .where('eventId', isEqualTo: eId)
          .snapshots()
          .map(_mapDocs);

  Stream<List<Map<String, dynamic>>> getLatestBookings({int limit = 3}) =>
      _firebase.reservationsCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map(_mapDocs);

  Future<int> getTotalActiveCount() async {
    final snapshot = await _firebase.reservationsCollection.count().get();
    return snapshot.count ?? 0;
  }

  Stream<List<Map<String, dynamic>>> getCheckinHistory({String? eventId}) {
    Query q = _firebase.reservationsCollection
        .where('isScanned', isEqualTo: true)
        .limit(500);
    if (eventId != null) {
      q = _firebase.reservationsCollection
          .where('isScanned', isEqualTo: true)
          .where('eventId', isEqualTo: eventId)
          .limit(500);
    }
    return q.snapshots().map(_mapDocs);
  }

  Future<Map<String, dynamic>> checkIn(String code) async {
    final docRef = _firebase.reservationsCollection.doc(code);
    late Map<String, dynamic> ticket;
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final doc = await tx.get(docRef);
      if (!doc.exists) throw Exception('ticket_not_found');
      ticket = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
      if (ticket['checkedInAt'] != null) {
        throw Exception('already_checked_in:${ticket['checkedInAt']}');
      }
      final now = DateTime.now().toIso8601String();
      tx.update(docRef, {'checkedInAt': now, 'isScanned': true});
      ticket['checkedInAt'] = now;
    });
    return ticket;
  }

  /// Hard-delete user's own reservation atomically.
  /// Decrements the event counter and deletes the reservation in one transaction.
  Future<void> deleteReservation(
      String resId, String eventId, String gender) async {
    if (eventId.isEmpty) {
      await _firebase.reservationsCollection.doc(resId).delete();
      return;
    }
    final field = gender == 'male' ? 'maleBooked' : 'femaleBooked';
    final eventRef = _firebase.eventsCollection.doc(eventId);
    final resRef = _firebase.reservationsCollection.doc(resId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(eventRef);
      if (snap.exists) {
        final current = (snap.data() as Map?)?[field] as int? ?? 0;
        tx.update(eventRef, {field: (current - 1).clamp(0, current)});
      }
      tx.delete(resRef);
    });
  }

  Future<void> deleteReservations(
    List<Map<String, dynamic>> tickets, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (tickets.isEmpty) return;

    // Group by eventId+gender to compute per-group decrements
    final Map<String, Map<String, dynamic>> groups = {};
    for (final t in tickets) {
      final eId = t['eventId'] as String? ?? '';
      final gender = t['gender'] as String? ?? 'male';
      final key = '$eId\x00$gender';
      groups.putIfAbsent(
          key, () => {'eventId': eId, 'gender': gender, 'count': 0});
      groups[key]!['count'] = (groups[key]!['count'] as int) + 1;
    }

    // Decrement counters sequentially (each in its own transaction)
    // then batch-delete the docs. If batch fails, counters are wrong —
    // acceptable for admin bulk-delete which is rare and recoverable.
    for (final g in groups.values) {
      await _decrementBookedCount(
          g['eventId'] as String, g['gender'] as String, g['count'] as int);
    }

    const batchSize = 500;
    int completed = 0;
    for (var i = 0; i < tickets.length; i += batchSize) {
      final chunk =
          tickets.sublist(i, (i + batchSize).clamp(0, tickets.length));
      final batch = FirebaseFirestore.instance.batch();
      for (final t in chunk) {
        batch.delete(_firebase.reservationsCollection.doc(t['id'] as String));
      }
      await batch.commit();
      completed += chunk.length;
      onProgress?.call(completed.clamp(0, tickets.length), tickets.length);
    }
  }

  Future<void> _decrementBookedCount(
      String eventId, String gender, int count) async {
    if (eventId.isEmpty) return;
    final field = gender == 'male' ? 'maleBooked' : 'femaleBooked';
    final eventRef = _firebase.eventsCollection.doc(eventId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(eventRef);
      if (!snap.exists) return;
      final current = (snap.data() as Map?)?[field] as int? ?? 0;
      tx.update(eventRef, {field: (current - count).clamp(0, current)});
    });
  }
}
