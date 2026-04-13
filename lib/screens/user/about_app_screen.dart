import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../utils/app_text.dart';
import '../../providers/language_provider.dart';
import '../../services/content_service.dart';
import '../../widgets/gradient_app_bar.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService().getContent('about_app');
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.aboutApp(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // App Name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Version
            Text(
              '${AppText.versionLabel(context)} ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Firebase content if available, else static fallback
            FutureBuilder<Map<String, dynamic>?>(
              future: _future,
              builder: (context, snap) {
                final isEn = context.watch<LanguageProvider>().currentLanguage == 'en';

                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snap.data;
                final enContent = (data?['en'] as String? ?? '').trim();
                final jaContent = (data?['ja'] as String? ?? '').trim();
                final firebaseContent = isEn
                    ? (enContent.isNotEmpty ? enContent : jaContent)
                    : (jaContent.isNotEmpty ? jaContent : enContent);

                // Firebase content available — show it
                if (firebaseContent.isNotEmpty) {
                  return Text(firebaseContent,
                      style: const TextStyle(fontSize: 15, height: 1.7));
                }

                // Fallback — static content
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      context: context,
                      icon: Icons.info_outline,
                      label: AppText.about(context),
                      value: AppText.aboutDescription(context),
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      context: context,
                      icon: Icons.language,
                      label: AppText.languages(context),
                      value: 'English / 日本語',
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      context: context,
                      icon: Icons.email_outlined,
                      label: AppText.contact(context),
                      value: AppConstants.contactEmail,
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      context: context,
                      icon: Icons.copyright,
                      label: AppText.copyright(context),
                      value: AppText.copyrightText(context),
                    ),
                  ],
                );
              },
            ),

            Text(
              AppText.madeWithLove(context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext buildContext) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(buildContext).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
