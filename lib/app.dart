import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_text.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/my_tickets_screen.dart';
import 'screens/user/profile_screen.dart';
import 'widgets/bottom_nav.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // FIX-020: Update last_activity on resume so 24h timeout tracks inactivity
      try {
        Provider.of<AuthProvider>(context, listen: false).updateActivity();
      } catch (_) {}
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    MyTicketsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          final navigator = Navigator.of(context);
          AppRoutes.showConfirmDialog(
            context,
            title: 'Exit App',
            message: 'Do you want to exit the app?',
            confirmText: AppText.yes(context),
            cancelText: AppText.no(context),
          ).then((confirmed) {
            if (confirmed == true) {
              navigator.popUntil((route) => route.isFirst);
            }
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class EventifyApp extends StatelessWidget {
  const EventifyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Set navigator key for in-app notifications
    NotificationService.navigatorKey = navigatorKey;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, __) => Consumer<LanguageProvider>(
          builder: (context, languageProvider, __) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Best Evento',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode:
                  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              locale: Locale(languageProvider.currentLanguage),
              initialRoute: AppRoutes.home,
              routes: AppRoutes.getRoutes(),
            );
          },
        ),
      ),
    );
  }
}
