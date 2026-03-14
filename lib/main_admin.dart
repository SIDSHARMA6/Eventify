import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/cloudinary_service.dart';
import 'config/theme.dart';
import 'config/admin_routes.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_home_wrapper.dart';

/// Admin App Entry Point
/// Build command: flutter build apk --target lib/main_admin.dart --release
/// Run command:   flutter run --target lib/main_admin.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase services
  await FirebaseService().initialize();
  await NotificationService().initialize();

  // Initialize Cloudinary (free image hosting)
  CloudinaryService().initialize();

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Best Evento Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // Admin app starts directly at home with bottom nav
            home: const AdminHomeWrapper(),
            routes: AdminRoutes.getRoutes(),
            onGenerateRoute: (settings) {
              // Handle dynamic routes if needed
              return null;
            },
          );
        },
      ),
    );
  }
}
