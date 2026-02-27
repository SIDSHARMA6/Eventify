import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/demo_data_provider.dart';
import '../config/constants.dart';
import '../data/dummy_data.dart';
import 'gradient_app_bar.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? selectedLocation;
  final Function(String)? onLocationChanged;

  const TopBar({
    super.key,
    this.selectedLocation,
    this.onLocationChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      title: Text(
        AppConstants.appName,
        style: Theme.of(context)
            .appBarTheme
            .titleTextStyle
            ?.copyWith(color: Colors.white),
      ),
      actions: [
        // 📍 Location Icon
        if (selectedLocation != null && onLocationChanged != null)
          Consumer2<LanguageProvider, DemoDataProvider>(
            builder: (context, langProvider, _, __) => PopupMenuButton<String>(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onSelected: onLocationChanged!,
              itemBuilder: (context) {
                return DummyData.locations.map((location) {
                  final nameEn = location['name_en'] as String;
                  final nameJa = location['name_ja'] as String? ?? nameEn;
                  final displayName =
                      langProvider.currentLanguage == 'en' ? nameEn : nameJa;

                  return PopupMenuItem<String>(
                    value: nameEn,
                    child: Text(displayName),
                  );
                }).toList();
              },
            ),
          ),

        // 🌐 Language Icon
        Consumer<LanguageProvider>(
          builder: (context, langProvider, child) => PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (value) => langProvider.switchLanguage(value),
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Text('English'),
                ),
                PopupMenuItem<String>(
                  value: 'ja',
                  child: Text('日本語'),
                ),
              ];
            },
          ),
        ),

        // 🔔 Notification Icon
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}
