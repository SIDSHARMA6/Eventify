import 'package:flutter/material.dart';

/// App Theme - ONLY place to define colors
/// Change colors here to update entire app
///
/// Color Scheme: Deep Indigo Gradients
/// Main: Deep Indigo (#1e1b4b) with light to dark shades
/// Reference: Soft Rose (#fce7f3), Warm White (#fafafa), Gold Accent (#d4a373)
class AppTheme {
  // ============================================
  // PRIMARY COLORS - Blue Gradient (#4439C6 → #0A68F4)
  // ============================================
  static const Color primaryDarkBlue = Color(0xFF4439C6); // Gradient start
  static const Color primaryLightBlue = Color(0xFF0A68F4); // Gradient end
  static const Color indigoMedium = Color(0xFF2E4FD8); // Medium shade
  static const Color indigoLight = Color(0xFF1E5FE0); // Light shade
  static const Color indigoLighter = Color(0xFF0A68F4); // Lighter shade
  static const Color indigoLightest = Color(0xFF3B82F6); // Lightest shade

  // Reference Colors (for accents and highlights)
  static const Color softRose = Color(0xFFfce7f3); // Soft Rose
  static const Color warmWhite = Color(0xFFfafafa); // Warm White
  static const Color goldAccent = Color(0xFFd4a373); // Gold Accent

  // Primary Color Assignments
  static const Color primaryColor = primaryDarkBlue; // Main primary (#4439C6)
  static const Color primaryDark = Color(0xFF2E1FA8); // Darker variant
  static const Color primaryLight = primaryLightBlue; // Light variant (#0A68F4)
  static const Color accentColor = goldAccent; // Gold accent for highlights

  // Background Colors
  static const Color backgroundLight = warmWhite; // Warm white background
  static const Color backgroundDark =
      Color(0xFF0a0a1a); // Very dark indigo-black
  static const Color surfaceLight = Color(0xFFf5f5f7); // Light surface
  static const Color surfaceDark = Color(0xFF1a1a2e); // Dark indigo surface

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1a1a2e); // Dark text on light
  static const Color textSecondaryLight =
      Color(0xFF64748b); // Secondary text light
  static const Color textPrimaryDark = warmWhite; // Light text on dark
  static const Color textSecondaryDark =
      Color(0xFFcbd5e1); // Secondary text dark

  // Status Colors
  static const Color errorColor = Color(0xFFef4444);
  static const Color successColor = Color(0xFF10b981);
  static const Color warningColor = goldAccent; // Using gold for warnings

  // Gender Colors (for male/female pricing)
  static const Color maleColor = Color(0xFF3b82f6); // Blue
  static const Color femaleColor = Color(0xFFec4899); // Pink

  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,

    colorScheme: ColorScheme.light(
      primary: primaryColor, // Deep indigo
      onPrimary: Colors.white,
      primaryContainer: indigoLightest, // Lightest indigo
      onPrimaryContainer: primaryDark,

      secondary: goldAccent, // Gold accent
      onSecondary: primaryDark,
      secondaryContainer: Color(0xFFf3e8d9), // Light gold
      onSecondaryContainer: primaryDark,

      tertiary: softRose, // Soft rose
      onTertiary: primaryDark,
      tertiaryContainer: Color(0xFFfdf2f8), // Very light rose
      onTertiaryContainer: primaryDark,

      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerHighest: Color(0xFFe2e8f0),

      error: errorColor,
      onError: Colors.white,

      outline: Color(0xFFcbd5e1),
      shadow: primaryColor.withValues(alpha: 0.1),
    ),

    // AppBar Theme - Deep Indigo Gradient
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme - Elevated with subtle shadow
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: primaryColor.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryLight,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimaryLight,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondaryLight,
        height: 1.4,
      ),
    ),

    // Button Theme - Deep Indigo with gradient effect
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryColor, width: 2),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: goldAccent,
      foregroundColor: primaryDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: textSecondaryLight),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: indigoLightest.withValues(alpha: 0.2),
      selectedColor: primaryColor,
      labelStyle: const TextStyle(color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textPrimaryLight,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFFe2e8f0),
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: Color(0xFFe2e8f0),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: indigoLighter,
    scaffoldBackgroundColor: backgroundDark,

    colorScheme: ColorScheme.dark(
      primary: indigoLighter, // Lighter indigo for dark mode
      onPrimary: primaryDark,
      primaryContainer: indigoMedium,
      onPrimaryContainer: indigoLightest,

      secondary: goldAccent, // Gold accent
      onSecondary: primaryDark,
      secondaryContainer: Color(0xFF8b6f47), // Darker gold
      onSecondaryContainer: warmWhite,

      tertiary: softRose, // Soft rose
      onTertiary: primaryDark,
      tertiaryContainer: Color(0xFF831843), // Darker rose
      onTertiaryContainer: softRose,

      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerHighest: Color(0xFF2d2d44),

      error: errorColor,
      onError: Colors.white,

      outline: Color(0xFF475569),
      shadow: Colors.black.withValues(alpha: 0.3),
    ),

    // AppBar Theme - Dark with gradient
    appBarTheme: AppBarTheme(
      backgroundColor:
          indigoMedium, // Use medium indigo instead of dark surface
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: indigoLightest,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryDark,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimaryDark,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondaryDark,
        height: 1.4,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: indigoLighter,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: indigoLightest,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: indigoLightest, width: 2),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: indigoLightest,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: goldAccent,
      foregroundColor: primaryDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2d2d44),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: indigoLightest, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: textSecondaryDark),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: indigoMedium.withValues(alpha: 0.3),
      selectedColor: indigoLighter,
      labelStyle: const TextStyle(color: indigoLightest),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textPrimaryDark,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF475569),
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: indigoLightest,
      linearTrackColor: Color(0xFF475569),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: indigoMedium,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  // ============================================
  // GRADIENT HELPERS
  // ============================================

  /// AppBar Gradient (Primary Blue Gradient)
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDarkBlue, // #4439C6
      primaryLightBlue, // #0A68F4
    ],
  );

  /// Blue Gradient (Light to Dark)
  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      indigoLightest, // Lightest
      indigoLighter, // Lighter
      indigoLight, // Light
      indigoMedium, // Medium
      primaryDarkBlue, // Darkest
    ],
  );

  /// Blue Gradient (Top to Bottom)
  static const LinearGradient indigoGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      indigoLighter,
      primaryDarkBlue,
    ],
  );

  /// Subtle Blue Gradient for Cards
  static LinearGradient indigoGradientSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      indigoLightest.withValues(alpha: 0.1),
      primaryDarkBlue.withValues(alpha: 0.05),
    ],
  );

  /// Gold Accent Gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFf3e8d9),
      goldAccent,
      Color(0xFFb8935f),
    ],
  );

  /// Pink Gradient for Venue Name and Map Button (#FF00FF → #FE008B)
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF00FF), // Magenta
      Color(0xFFFE008B), // Deep Pink
    ],
  );
}
