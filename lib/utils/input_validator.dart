import 'package:flutter/foundation.dart';

/// Input validation utility for security and data integrity
class InputValidator {
  // Prevent instantiation
  InputValidator._();

  /// Validate event title (2-100 chars, no XSS)
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Title must be at least 2 characters';
    if (trimmed.length > 100) return 'Title must be less than 100 characters';
    return _checkXSS(trimmed);
  }

  /// Validate event description (10-2000 chars, no XSS)
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (trimmed.length > 2000) {
      return 'Description must be less than 2000 characters';
    }
    return _checkXSS(trimmed);
  }

  /// Validate location (2-100 chars, no XSS)
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Location must be at least 2 characters';
    if (trimmed.length > 100) {
      return 'Location must be less than 100 characters';
    }
    return _checkXSS(trimmed);
  }

  /// Validate venue name (2-150 chars, no XSS)
  static String? validateVenue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Venue is optional
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Venue must be at least 2 characters';
    if (trimmed.length > 150) return 'Venue must be less than 150 characters';
    return _checkXSS(trimmed);
  }

  /// Validate venue address (5-200 chars, no XSS)
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Address is optional
    }
    final trimmed = value.trim();
    if (trimmed.length < 5) return 'Address must be at least 5 characters';
    if (trimmed.length > 200) {
      return 'Address must be less than 200 characters';
    }
    return _checkXSS(trimmed);
  }

  /// Validate price (must be non-negative integer)
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = int.tryParse(value.trim());
    if (price == null) return 'Price must be a number';
    if (price < 0) return 'Price cannot be negative';
    if (price > 1000000) return 'Price is too high';
    return null;
  }

  /// Validate limit (must be positive integer, max 10000)
  static String? validateLimit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Limit is required';
    }
    final limit = int.tryParse(value.trim());
    if (limit == null) return 'Limit must be a number';
    if (limit <= 0) return 'Limit must be greater than 0';
    if (limit > 10000) return 'Limit cannot exceed 10,000';
    return null;
  }

  /// Validate URL (must be HTTPS only)
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }
    final trimmed = value.trim();
    if (!trimmed.startsWith('https://')) {
      return 'URL must use HTTPS (secure connection)';
    }
    try {
      final uri = Uri.parse(trimmed);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Invalid URL format';
      }
    } catch (e) {
      return 'Invalid URL format';
    }
    return null;
  }

  /// Check for XSS patterns
  static String? _checkXSS(String value) {
    final dangerous = [
      '<script',
      '</script',
      'javascript:',
      'onerror=',
      'onclick=',
      'onload=',
      '<iframe',
      '<object',
      '<embed',
    ];
    final lower = value.toLowerCase();
    for (final pattern in dangerous) {
      if (lower.contains(pattern)) {
        return 'Invalid characters detected';
      }
    }
    return null;
  }

  /// Sanitize text by removing dangerous characters
  static String sanitize(String value) {
    return value
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }

  /// Validate user name for booking (2-50 chars, safe characters only)
  static String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    if (trimmed.length > 50) return 'Name must be less than 50 characters';

    // Allow letters, spaces, hyphens, apostrophes, Japanese/Chinese characters
    final validNameRegex =
        RegExp(r"^[a-zA-Z\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\s\-']+$");
    if (!validNameRegex.hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }

    return _checkXSS(trimmed);
  }

  /// Log validation errors in debug mode only
  static void logError(String field, String? error) {
    if (kDebugMode && error != null) {
      debugPrint('⚠️ Validation Error [$field]: $error');
    }
  }
}
