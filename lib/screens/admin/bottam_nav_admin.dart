import 'package:eventify/widgets/gradient_icon.dart';
import 'package:flutter/material.dart';


class BottomNavAdmin extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavAdmin({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: currentIndex == 0
              ? const GradientIcon(icon: Icons.event)
              : const Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 1
              ? const GradientIcon(icon: Icons.confirmation_number)
              : const Icon(Icons.confirmation_number),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 2
              ? const GradientIcon(icon: Icons.person)
              : const Icon(Icons.person),
          label: 'admin-profile',
        ),
      ],
    );
  }
}
