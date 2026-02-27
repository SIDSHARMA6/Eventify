/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Best Event 🎉';
  static const String appVersion = '1.0.0';

  // Default Values
  static const String defaultLanguage = 'en'; // English
  static const bool defaultThemeIsDark = false; // Light mode

  // SharedPreferences Keys
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyDeviceId = 'device_id';
  static const String keyTickets = 'my_tickets';

  // Dummy Data
  static const String dummyImageUrl = 'https://picsum.photos/400/300';

  // Pagination
  static const int eventsPerPage = 10;
  static const int ticketsPerPage = 20;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Contact Links
  static const String contactEmail = 'official.bestevent@gmail.com';
  static const String contactLineUrl = 'https://line.me/ti/p/FDcnAhz9f';
  static const String privacyPolicyUrl = 'https://bestparty.com/privacy';
  static const String contactUsUrl = 'https://bestparty.com/contact';

  // App Store Links
  static const String appStoreUrl = 'https://apps.apple.com/app/best-event';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.bestevent';
}
