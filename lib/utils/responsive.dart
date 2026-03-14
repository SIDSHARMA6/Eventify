import 'package:flutter/material.dart';

/// Responsive Helper — provides adaptive padding based on screen width.
class Responsive {
  static bool _isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool _isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1200;
  }

  /// Adaptive horizontal/vertical padding: 12 / 16 / 24 dp
  static double padding(BuildContext context) {
    if (_isSmall(context)) return 12.0;
    if (_isMedium(context)) return 16.0;
    return 24.0;
  }
}
