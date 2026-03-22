import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// Helper functions for handling bilingual content with fallback
class LanguageHelper {
  /// Get text with fallback to English if Japanese is empty/null
  static String getText(
    String? englishText,
    String? japaneseText,
    bool isJapanese,
  ) {
    if (isJapanese) {
      if (japaneseText == null || japaneseText.trim().isEmpty) {
        return englishText ?? '';
      }
      return japaneseText;
    }
    return englishText ?? '';
  }

  /// Get event title with fallback
  static String getEventTitle(Map<String, dynamic> event, bool isJapanese) {
    return getText(event['title_en'], event['title_ja'], isJapanese);
  }

  /// Get event description with fallback
  static String getEventDescription(
      Map<String, dynamic> event, bool isJapanese) {
    return getText(
        event['description_en'], event['description_ja'], isJapanese);
  }

  /// Get venue name with fallback
  static String getVenueName(Map<String, dynamic> event, bool isJapanese) {
    return getText(
      event['venueName_en'] ?? event['venueName'],
      event['venueName_ja'],
      isJapanese,
    );
  }

  /// Get images with fallback to English if Japanese is empty
  static List<String> getImages(Map<String, dynamic> event, bool isJapanese) {
    if (isJapanese) {
      final jaImages = event['images_ja'];
      if (jaImages != null &&
          jaImages is List &&
          jaImages.isNotEmpty &&
          jaImages[0] != null &&
          jaImages[0].toString().isNotEmpty) {
        return List<String>.from(jaImages);
      }
    }
    final enImages = event['images_en'];
    if (enImages != null && enImages is List) {
      return List<String>.from(enImages);
    }
    return [];
  }

  static bool isJapanese(BuildContext context) {
    return Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'ja';
  }
}
