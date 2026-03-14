import 'package:flutter/material.dart';

// Auth Screens
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_home_wrapper.dart';

// Admin Screens
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_events_screen.dart';
import '../screens/admin/manage_locations_screen.dart';
import '../screens/admin/manage_creators_screen.dart';
import '../screens/admin/creator_summary_screen.dart';
import '../screens/admin/qr_scanner_screen.dart';
import '../screens/admin/checkin_history_screen.dart';
import '../screens/user/about_app_screen.dart';
import '../screens/user/privacy_policy_screen.dart';

// Creator Screens (used by admin)
import '../screens/creator/create_event_screen.dart';
import '../screens/creator/event_stats_screen.dart';

/// Admin App Routes
/// Separate routes for the admin app to keep it isolated from user app
class AdminRoutes {
  // ============================================
  // AUTH ROUTES
  // ============================================
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String home = '/home';

  // ============================================
  // ADMIN ROUTES
  // ============================================
  static const String adminDashboard = '/admin-dashboard';
  static const String manageEvents = '/manage-events';
  static const String manageLocations = '/manage-locations';
  static const String manageCreators = '/manage-creators';
  static const String creatorSummary = '/creator-summary';
  static const String qrScanner = '/qr-scanner';
  static const String checkinHistory = '/checkin-history';
  static const String aboutApp = '/about-app';
  static const String privacyPolicy = '/privacy-policy';

  // ============================================
  // CREATOR ROUTES (used by admin)
  // ============================================
  static const String createEvent = '/create-event';
  static const String eventStats = '/event-stats';

  /// Get all routes for admin app
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Auth
      login: (context) => const AdminLoginScreen(),
      adminLogin: (context) => const AdminLoginScreen(),
      home: (context) => const AdminHomeWrapper(),

      // Admin
      adminDashboard: (context) => const AdminDashboardScreen(),
      manageEvents: (context) => const ManageEventsScreen(),
      manageLocations: (context) => const ManageLocationsScreen(),
      manageCreators: (context) => const ManageCreatorsScreen(),
      creatorSummary: (context) => const CreatorSummaryScreen(),
      qrScanner: (context) => const QRScannerScreen(),
      checkinHistory: (context) => const CheckinHistoryScreen(),
      aboutApp: (context) => const AboutAppScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),
    };
  }

  /// Navigate to a route
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// Navigate and replace current route
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// Navigate and clear all previous routes
  static void navigateAndClearAll(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  /// Navigate to create event screen
  static void navigateToCreateEvent(
    BuildContext context, {
    required String creatorId,
    Map<String, dynamic>? event,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          creatorId: creatorId,
          event: event,
        ),
      ),
    );
  }

  /// Navigate to event stats screen
  static void navigateToEventStats(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventStatsScreen(event: event),
      ),
    );
  }

  /// Navigate to manage events with filter
  static void navigateToManageEventsFiltered(
    BuildContext context,
    String filterByEmail,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageEventsScreen(filterByEmail: filterByEmail),
      ),
    );
  }

  /// Navigate to checkin history with filter
  static void navigateToCheckinHistoryFiltered(
    BuildContext context,
    String eventId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckinHistoryScreen(eventId: eventId),
      ),
    );
  }
}
