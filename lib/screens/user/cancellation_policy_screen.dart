import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/web_view_screen.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
    return WebViewScreen(
      url: 'https://officialbestevent.wixsite.com/bestevento/blank-1',
      titleEn: 'Cancellation Policy',
      titleJa: 'キャンセルポリシー',
      isJa: isJa,
    );
  }
}
