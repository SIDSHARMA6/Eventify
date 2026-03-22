import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/web_view_screen.dart';

class CommercialDisclosureScreen extends StatelessWidget {
  const CommercialDisclosureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isJa =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguage ==
            'ja';
    return WebViewScreen(
      url:
          'https://officialbestevent.wixsite.com/bestevento/commercial-disclosure',
      titleEn: 'Commercial Disclosure',
      titleJa: '特定商取引法に基づく表記',
      isJa: isJa,
    );
  }
}
