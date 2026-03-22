import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_service.dart';
import 'device_service.dart';
import 'event_service.dart';
import 'rate_limiter.dart';
import 'notification_service.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final _firebase = FirebaseService();
  final _device = DeviceService();
  final _event = EventService();
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
    if (!_rateLimiter.isAllowed(deviceId, 'booking')) {
      throw Exception('Too many attempts.');
    }

    final docId = '${deviceId}_$eventId';
    final event = await _event.getEventById(eventId) ??
        (throw Exception('Event not found'));

    final limit = (gender == 'male' ? event['maleLimit'] : event['femaleLimit'])
            as int? ??
        0;
    final booked = (gender == 'male'
            ? event['maleBooked']
            : event['femaleBooked']) as int? ??
        0;

    if (limit <= 0) throw Exception('No tickets for $gender');
    if (booked >= limit) throw Exception('Sold out for $gender');

    final tId =
        'TICKET-${List.generate(12, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'[Random.secure().nextInt(62)]).join()}';

    final reservation = {
      'eventId': eventId,
      'deviceId': deviceId,
      'userName': userName,
      'gender': gender,
      'ticketId': tId,
      'timestamp': DateTime.now().toIso8601String(),
      'isCancelled': false,
      'isScanned': false,
      'checkedInAt': null,
      'eventTitle_en': event['title_en'] ?? '',
      'eventTitle_ja': event['title_ja'] ?? '',
      'eventDate': event['date'] ?? '',
      'eventTime': event['startTime'] ?? '',
      'eventImage': (event['images_en'] as List?)?.firstOrNull,
    };

    final docRef = _firebase.reservationsCollection.doc(docId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final existing = await tx.get(docRef);
      if (existing.exists &&
          (existing.data() as Map?)?['isCancelled'] == false) {
        throw Exception('Already have a ticket');
      }
      tx.set(docRef, reservation);
    });

    await _event.incrementBookedCount(eventId, gender);
    await _notifications.sendTicketConfirmation(
      eventTitle: event['title_en'] ?? '',
      ticketId: tId,
    );

    return {...reservation, 'id': docId};
  }

  Future<bool> hasExistingReservation(String dId, String eId) async {
    final doc = await _firebase.reservationsCollection.doc('${dId}_$eId').get();
    if (!doc.exists) return false;
    return (doc.data() as Map?)?['isCancelled'] == false;
  }

  Stream<bool> watchReservation(String dId, String eId) {
    return _firebase.reservationsCollection
        .doc('${dId}_$eId')
        .snapshots()
        .map((snap) {
      if (!snap.exists) return false;
      return (snap.data() as Map?)?['isCancelled'] == false;
    });
  }

  /// My active tickets — no isDeleted filter (hard delete model)
  Stream<List<Map<String, dynamic>>> getMyReservations() =>
      Stream.fromFuture(_device.getDeviceId()).asyncExpand((dId) => _firebase
          .reservationsCollection
          .where('deviceId', isEqualTo: dId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(_mapDocs));

  /// All reservations for an event (active + cancelled) — for stats screen
  Stream<List<Map<String, dynamic>>> getAllReservationsByEvent(String eId) =>
      _firebase.reservationsCollection
          .where('eventId', isEqualTo: eId)
          .snapshots()
          .map(_mapDocs);

  /// Active reservations for an event only
  Stream<List<Map<String, dynamic>>> getReservationsByEvent(String eId) =>
      _firebase.reservationsCollection
          .where('eventId', isEqualTo: eId)
          .where('isCancelled', isEqualTo: false)
          .snapshots()
          .map(_mapDocs);

  /// Latest N active bookings for home screen
  Stream<List<Map<String, dynamic>>> getLatestBookings({int limit = 3}) =>
      _firebase.reservationsCollection
          .where('isCancelled', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map(_mapDocs);

  /// Total active ticket count — single field query, no composite index needed
  Stream<int> getTotalActiveCount() => _firebase.reservationsCollection
      .where('isCancelled', isEqualTo: false)
      .snapshots()
      .map((s) => s.docs.length);

  Stream<List<Map<String, dynamic>>> getCheckinHistory({String? eventId}) {
    Query q =
        _firebase.reservationsCollection.where('isScanned', isEqualTo: true);
    if (eventId != null) q = q.where('eventId', isEqualTo: eventId);
    return q.snapshots().map(_mapDocs);
  }

  /// Check in a ticket by reservation doc ID.
  Future<Map<String, dynamic>> checkIn(String code) async {
    final doc = await _firebase.reservationsCollection.doc(code).get();
    if (!doc.exists) throw Exception('ticket_not_found');
    final ticket = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
    if (ticket['checkedInAt'] != null) {
      throw Exception('already_checked_in:${ticket['checkedInAt']}');
    }
    final now = DateTime.now().toIso8601String();
    await _firebase.reservationsCollection
        .doc(code)
        .update({'checkedInAt': now, 'isScanned': true});
    return {...ticket, 'checkedInAt': now};
  }

  Future<void> cancelReservation(
      String resId, String eventId, String gender) async {
    await _firebase.reservationsCollection.doc(resId).update(
        {'isCancelled': true, 'cancelledAt': FieldValue.serverTimestamp()});
    await _decrementBookedCount(eventId, gender, 1);
  }

  Future<void> deleteReservation(
      String resId, String eventId, String gender) async {
    await _decrementBookedCount(eventId, gender, 1);
    await _firebase.reservationsCollection.doc(resId).delete();
  }

  Future<void> deleteReservations(
    List<Map<String, dynamic>> tickets, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (tickets.isEmpty) return;
    final total = tickets.length;

    final Map<String, Map<String, dynamic>> groups = {};
    for (final t in tickets) {
      final eventId = t['eventId'] as String? ?? '';
      final gender = t['gender'] as String? ?? 'male';
      final key = '$eventId\x00$gender';
      groups.putIfAbsent(
          key, () => {'eventId': eventId, 'gender': gender, 'count': 0});
      groups[key]!['count'] = (groups[key]!['count'] as int) + 1;
    }

    await Future.wait(groups.values.map((g) => _decrementBookedCount(
        g['eventId'] as String, g['gender'] as String, g['count'] as int)));

    for (var i = 0; i < tickets.length; i++) {
      await _firebase.reservationsCollection
          .doc(tickets[i]['id'] as String)
          .delete();
      onProgress?.call(i + 1, total);
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
