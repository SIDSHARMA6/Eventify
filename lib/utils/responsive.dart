import 'package:flutter/material.dart';

/// Responsive Helper
/// Use this for responsive sizing across all screens
class Responsive {
  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Check if small screen (< 600px)
  static bool isSmallScreen(BuildContext context) {
    return width(context) < 600;
  }
  
  /// Check if medium screen (600px - 1200px)
  static bool isMediumScreen(BuildContext context) {
    return width(context) >= 600 && width(context) < 1200;
  }
  
  /// Check if large screen (>= 1200px)
  static bool isLargeScreen(BuildContext context) {
    return width(context) >= 1200;
  }
  
  /// Get responsive padding
  static double padding(BuildContext context) {
    if (isSmallScreen(context)) return 12.0;
    if (isMediumScreen(context)) return 16.0;
    return 24.0;
  }
  
  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) return baseSize * 0.9;
    if (isMediumScreen(context)) return baseSize;
    return baseSize * 1.1;
  }
  
  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) return baseSize * 0.9;
    if (isMediumScreen(context)) return baseSize;
    return baseSize * 1.1;
  }
  
  /// Get number of columns for grid
  static int gridColumns(BuildContext context) {
    if (isSmallScreen(context)) return 1;
    if (isMediumScreen(context)) return 2;
    return 3;
  }
  
  /// Get responsive width percentage
  static double widthPercent(BuildContext context, double percent) {
    return width(context) * (percent / 100);
  }
  
  /// Get responsive height percentage
  static double heightPercent(BuildContext context, double percent) {
    return height(context) * (percent / 100);
  }
}
