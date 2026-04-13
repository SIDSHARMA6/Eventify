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

  // ── Cached last values — new subscribers get data instantly, no spinner ──
  List<Map<String, dynamic>>? _eventsCache;
  List<Map<String, dynamic>>? _allEventsCache;

  // ── Persistent streams stored on the singleton ───────────────────────────
  late final Stream<List<Map<String, dynamic>>> _eventsStream =
      _firebase.eventsCollection.orderBy('date').snapshots().map((s) {
    final result = _mapDocs(s).where((e) => e['isHidden'] != true).toList();
    _eventsCache = result;
    return result;
  }).asBroadcastStream();

  late final Stream<List<Map<String, dynamic>>> _allEventsStream = _firebase
      .eventsCollection
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) {
    final result = _mapDocs(s);
    _allEventsCache = result;
    return result;
  }).asBroadcastStream();

  /// Visible events only. Returns cached data immediately on first frame,
  /// then live updates. No spinner ever shown.
  Stream<List<Map<String, dynamic>>> getEvents() async* {
    if (_eventsCache != null) yield _eventsCache!;
    yield* _eventsStream;
  }

  /// All events including hidden (admin). Returns cached data immediately.
  Stream<List<Map<String, dynamic>>> getAllEvents() async* {
    if (_allEventsCache != null) yield _allEventsCache!;
    yield* _allEventsStream;
  }

  /// Visible events filtered by location — kept for completeness but
  /// filtering is done client-side in HomeScreen via _filterAndSort.
  /// DO NOT USE from new call sites — may be removed in a future cleanup.
  @Deprecated('Filter client-side via HomeScreen._filterAndSort instead')
  Stream<List<Map<String, dynamic>>> getEventsByLocation(String loc) =>
      loc == 'All'
          ? _eventsStream
          : _firebase.eventsCollection
              .where('isHidden', isEqualTo: false)
              .where('location_en', isEqualTo: loc)
              .orderBy('date')
              .snapshots()
              .map(_mapDocs);

  Stream<List<Map<String, dynamic>>> getEventsByCreator(String id) =>
      _firebase.eventsCollection
          .where('createdBy', isEqualTo: id)
          .orderBy('date', descending: true)
          .snapshots()
          .map(_mapDocs);

  /// One-time fetch (no listener) — use for delete/cascade operations.
  Future<List<Map<String, dynamic>>> getEventsByCreatorOnce(String id) async {
    final snap = await _firebase.eventsCollection
        .where('createdBy', isEqualTo: id)
        .get();
    return _mapDocs(snap);
  }

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
      // Preserve existing createdBy (e.g. when admin duplicates a creator's
      // event the original creator retains ownership).
      // Fall back to the currently authenticated user only for new events.
      'createdBy': data['createdBy'] ?? user.uid,
      'createdByEmail': data['createdByEmail'] ?? (user.email ?? ''),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'maleBooked': data['maleBooked'] ?? 0,
      'femaleBooked': data['femaleBooked'] ?? 0,
      'isHidden': data['isHidden'] ?? false,
    };
    final doc = await _firebase.eventsCollection.add(payload);
    // Don't send push notification for duplicated or hidden events
    if (data['isDuplicated'] != true && data['isHidden'] != true) {
      await _notification.sendNewEventNotification(
          data['title_en'], data['description_en']);
    }
    return doc.id;
  }

  Future<void> updateEvent(String id, Map<String, dynamic> updates) async =>
      await _firebase.eventsCollection.doc(id).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteEvent(String id) async {
    // Fetch in pages of 500 to avoid unbounded reads on large events
    QuerySnapshot snap;
    do {
      snap = await _firebase.reservationsCollection
          .where('eventId', isEqualTo: id)
          .limit(500)
          .get();
      if (snap.docs.isEmpty) break;
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snap.docs.length == 500);
    await _firebase.eventsCollection.doc(id).delete();
  }

  Future<void> toggleEventVisibility(String id, bool hidden) async =>
      await _firebase.eventsCollection.doc(id).update(
          {'isHidden': hidden, 'updatedAt': FieldValue.serverTimestamp()});
}
