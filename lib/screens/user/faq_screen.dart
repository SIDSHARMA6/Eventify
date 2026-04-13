import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/web_view_screen.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
    return WebViewScreen(
      url: 'https://officialbestevent.wixsite.com/bestevento/faqs',
      titleEn: 'FAQ',
      titleJa: 'よくある質問',
      isJa: isJa,
    );
  }
}
