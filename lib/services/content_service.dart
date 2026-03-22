import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Single source of truth for app_content Firestore collection.
class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  final _col = FirebaseService().firestore.collection('app_content');

  Future<Map<String, dynamic>?> getContent(String docId) async {
    final doc = await _col.doc(docId).get();
    return doc.data();
  }

  Future<void> saveContent(String docId, String en, String ja) async {
    await _col.doc(docId).set({
      'en': en,
      'ja': ja,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
