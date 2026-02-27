import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/language_provider.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          Provider.of<LanguageProvider>(context, listen: false)
                      .currentLanguage ==
                  'en'
              ? 'Cancellation Policy'
              : 'キャンセルポリシー',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                Provider.of<LanguageProvider>(context, listen: false)
                            .currentLanguage ==
                        'en'
                    ? 'Coming Soon'
                    : '準備中',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                Provider.of<LanguageProvider>(context, listen: false)
                            .currentLanguage ==
                        'en'
                    ? 'This page is currently under construction.\nPlease check back later.'
                    : 'このページは現在準備中です。\nしばらくお待ちください。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
