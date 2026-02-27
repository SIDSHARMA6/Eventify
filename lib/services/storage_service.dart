import 'dart:io';

import 'firebase_service.dart';

class StorageService {
  final FirebaseService _firebase = FirebaseService();

  // Upload event image
  Future<String> uploadEventImage(
      File imageFile, String eventId, String language) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'events/$eventId/$language/$fileName';

      final ref = _firebase.storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Upload image error: $e');
      rethrow;
    }
  }

  // Upload multiple event images
  Future<List<String>> uploadEventImages(
    List<File> imageFiles,
    String eventId,
    String language,
  ) async {
    try {
      final urls = <String>[];

      for (var imageFile in imageFiles) {
        final url = await uploadEventImage(imageFile, eventId, language);
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Upload multiple images error: $e');
      rethrow;
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _firebase.storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Delete image error: $e');
      rethrow;
    }
  }

  // Delete multiple images
  Future<void> deleteImages(List<String> imageUrls) async {
    try {
      for (var url in imageUrls) {
        await deleteImage(url);
      }
    } catch (e) {
      print('Delete multiple images error: $e');
      rethrow;
    }
  }
}
