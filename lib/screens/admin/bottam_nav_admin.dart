import 'package:eventify/widgets/gradient_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';

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
    context.watch<LanguageProvider>();
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: currentIndex == 0
              ? const GradientIcon(icon: Icons.event)
              : const Icon(Icons.event),
          label: AppText.events(context),
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 1
              ? const GradientIcon(icon: Icons.confirmation_number)
              : const Icon(Icons.confirmation_number),
          label: AppText.tickets(context),
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 2
              ? const GradientIcon(icon: Icons.person)
              : const Icon(Icons.person),
          label: AppText.profile(context),
        ),
      ],
    );
  }
}
