import 'package:flutter/material.dart';

// Main App
import '../app.dart';

// User Screens
import '../screens/user/event_details_screen.dart';
import '../screens/user/my_tickets_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/about_app_screen.dart';
import '../screens/user/privacy_policy_screen.dart';

// Creator Screens
import '../screens/creator/creator_login_screen.dart';
import '../screens/creator/creator_dashboard_screen.dart';
import '../screens/creator/create_event_screen.dart';
import '../screens/creator/event_stats_screen.dart';

// Admin Screens
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_events_screen.dart';
import '../screens/admin/manage_creators_screen.dart';
import '../screens/admin/manage_locations_screen.dart';
import '../screens/admin/qr_scanner_screen.dart';

/// Centralized routing configuration for the app
/// All navigation should use these routes for consistency
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // ============================================
  // USER ROUTES
  // ============================================
  static const String home = '/';
  static const String eventDetails = '/event-details';
  static const String tickets = '/tickets';
  static const String profile = '/profile';
  static const String adminProfile = '/admin-profile';
  static const String aboutApp = '/about-app';
  static const String privacyPolicy = '/privacy-policy';
  static const String calendar = '/calendar';

  // ============================================
  // CREATOR ROUTES
  // ============================================
  static const String creatorLogin = '/creator-login';
  static const String creatorDashboard = '/creator-dashboard';
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event';
  static const String eventStats = '/event-stats';

  // ============================================
  // ADMIN ROUTES
  // ============================================
  static const String adminDashboard = '/admin-dashboard';
  static const String manageEvents = '/manage-events';
  static const String manageCreators = '/manage-creators';
  static const String manageLocations = '/manage-locations';
  static const String qrScanner = '/qr-scanner';

  // ============================================
  // ROUTE MAP
  // ============================================
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // User Routes - Main App with Bottom Navigation
      home: (context) => const App(),

      // Individual User Screens (for direct navigation if needed)
      tickets: (context) => const MyTicketsScreen(),
      profile: (context) => const ProfileScreen(),
      aboutApp: (context) => const AboutAppScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),

      // Creator Routes
      creatorLogin: (context) => const CreatorLoginScreen(),
      creatorDashboard: (context) => const CreatorDashboardScreen(),

      // Admin Routes
      adminDashboard: (context) => const AdminDashboardScreen(),
      manageEvents: (context) => const ManageEventsScreen(),
      manageCreators: (context) => const ManageCreatorsScreen(),
      manageLocations: (context) => const ManageLocationsScreen(),
      qrScanner: (context) => const QRScannerScreen(),
    };
  }

  // ============================================
  // NAVIGATION HELPERS
  // ============================================

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName) {
    return Navigator.pushNamed<T>(context, routeName);
  }

  /// Navigate and replace current route
  static Future<T?> navigateReplaceTo<T>(
      BuildContext context, String routeName) {
    return Navigator.pushReplacementNamed<T, Object?>(context, routeName);
  }

  /// Navigate and clear all previous routes
  static Future<T?> navigateAndClearAll<T>(
      BuildContext context, String routeName) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
    );
  }

  /// Go back to previous screen
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  // ============================================
  // ROUTES WITH ARGUMENTS
  // ============================================

  /// Navigate to Event Details with event data
  static Future<T?> navigateToEventDetails<T>(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }

  /// Navigate to Create Event (for creating new or editing existing)
  static Future<T?> navigateToCreateEvent<T>(
    BuildContext context, {
    required String creatorId,
    Map<String, dynamic>? event,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          creatorId: creatorId,
          event: event,
        ),
      ),
    );
  }

  /// Navigate to Event Stats
  static Future<T?> navigateToEventStats<T>(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => EventStatsScreen(event: event),
      ),
    );
  }

  // ============================================
  // DIALOG HELPERS
  // ============================================

  /// Show a confirmation dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a message dialog
  static Future<void> showMessageDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a snackbar message
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
