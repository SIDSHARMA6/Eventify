import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/dummy_data.dart';
import 'firebase_service.dart';

class SeedingService {
  final FirebaseService _firebase = FirebaseService();

  Future<void> seedDatabase() async {
    try {
      print('🌱 Starting Database Seed...');

      // 1. Seed Locations
      final locationsRef = _firebase.locationsCollection;
      final locationSnapshot = await locationsRef.get();

      if (locationSnapshot.docs.isEmpty) {
        print('📍 Seeding Locations...');
        for (var location in DummyData.locations) {
          await locationsRef.add({
            'name_en': location['name_en'],
            'name_ja': location['name_ja'],
            'order': location['order'] ?? 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        print('📍 Locations already exist. Skipping.');
      }

      // 2. Seed Events
      final eventsRef = _firebase.eventsCollection;
      final eventSnapshot = await eventsRef.get();

      if (eventSnapshot.docs.isEmpty) {
        print('📅 Seeding Events...');
        for (var event in DummyData.events) {
          // Clean up event data for Firestore
          final eventData = Map<String, dynamic>.from(event);
          eventData.remove('id'); // Firestore generates ID

          // Ensure arrays are lists
          eventData['images_en'] = List<String>.from(eventData['images_en']);
          eventData['images_ja'] = List<String>.from(eventData['images_ja']);

          // Add metadata
          eventData['createdAt'] = FieldValue.serverTimestamp();
          eventData['updatedAt'] = FieldValue.serverTimestamp();
          eventData['createdBy'] = 'dummy-creator-id';
          eventData['isHidden'] = false;
          eventData['maleBooked'] = 0;
          eventData['femaleBooked'] = 0;

          await eventsRef.add(eventData);
        }
      } else {
        print('📅 Events already exist. Skipping.');
      }

      // 3. Seed Users (Creator & Admin)
      final usersRef = _firebase.usersCollection;

      // Create Admin User Document (Note: Authentication user must be created manually or via Auth SDK)
      await usersRef.doc('admin-test-id').set({
        'email': 'admin@eventify.com',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create Creator User Document
      await usersRef.doc('creator-test-id').set({
        'email': 'creator@eventify.com',
        'role': 'creator',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('👤 Seeding Users complete.');
      print('✅ Database Seeding Completed Successfully!');
    } catch (e) {
      print('❌ Error during seeding: $e');
      rethrow;
    }
  }
}
