import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/web_view_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
    return WebViewScreen(
      url: 'https://officialbestevent.wixsite.com/bestevento/blank',
      titleEn: 'Privacy Policy',
      titleJa: 'プライバシーポリシー',
      isJa: isJa,
    );
  }
}
