import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_text.dart';
import '../user/home_screen.dart';
import '../user/my_tickets_screen.dart';
import 'profile_screen_admin.dart';
import 'bottam_nav_admin.dart';

/// Admin App Wrapper - Same structure as User App
/// Home (browse events) + My Tickets (book tickets) + Profile (login with admin)
class AdminHomeWrapper extends StatefulWidget {
  const AdminHomeWrapper({super.key});

  @override
  State<AdminHomeWrapper> createState() => _AdminHomeWrapperState();
}

class _AdminHomeWrapperState extends State<AdminHomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(), // Browse events (same as user app)
    MyTicketsScreen(), // Book and view tickets (same as user app)
    ProfileScreenAdmin(), // Profile with "Login with Admin" button
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;


        // If not on home tab, go back to home
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          // Show exit confirmation
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppText.exitAppTitle(context)),
              content: Text(AppText.exitAppDesc(context)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppText.no(context)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppText.yes(context)),
                ),
              ],
            ),
          );
          if (shouldExit == true) SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavAdmin(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
