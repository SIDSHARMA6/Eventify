import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../config/constants.dart';
import '../services/location_management_service.dart';
import 'gradient_app_bar.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  Stream<List<Map<String, dynamic>>>? _locationsStream;

  @override
  void initState() {
    super.initState();
    if (widget.selectedLocation != null && widget.onLocationChanged != null) {
      _locationsStream = LocationManagementService().getAllLocations();
    }
  }

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
        if (widget.selectedLocation != null && widget.onLocationChanged != null)
          Consumer<LanguageProvider>(
            builder: (context, langProvider, _) {
              final isJapanese = langProvider.currentLanguage == 'ja';
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _locationsStream,
                builder: (context, snapshot) {
                  final locations = snapshot.data ?? [];
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    onSelected: widget.onLocationChanged!,
                    itemBuilder: (context) => locations.map((loc) {
                      final nameEn = loc['name_en'] as String? ?? '';
                      final nameJa = loc['name_ja'] as String? ?? nameEn;
                      return PopupMenuItem<String>(
                        value: nameEn,
                        child: Text(isJapanese ? nameJa : nameEn),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        Consumer<LanguageProvider>(
          builder: (context, langProvider, _) => PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: langProvider.switchLanguage,
            itemBuilder: (_) => const [
              PopupMenuItem<String>(value: 'en', child: Text('English')),
              PopupMenuItem<String>(value: 'ja', child: Text('日本語')),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}
