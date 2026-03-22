import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_text.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/gradient_icon.dart';
import 'commercial_disclosure_screen.dart';
import 'cancellation_policy_screen.dart';
import 'faq_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch language provider to rebuild when language changes
    context.watch<LanguageProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.profile(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),

          // Language Selection
          Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => ListTile(
              leading: const GradientIcon(icon: Icons.language),
              title: Text(AppText.language(context)),
              trailing: DropdownButton<String>(
                value: langProvider.currentLanguage,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(AppText.english(context)),
                  ),
                  DropdownMenuItem(
                    value: 'ja',
                    child: Text(AppText.japanese(context)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    langProvider.switchLanguage(value);
                  }
                },
              ),
            ),
          ),

          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => SwitchListTile(
              secondary: GradientIcon(
                icon: themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: Text(AppText.theme(context)),
              subtitle: Text(
                themeProvider.isDarkMode
                    ? AppText.darkMode(context)
                    : AppText.lightMode(context),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),

          const Divider(),

          // Login with Creator
          ListTile(
            leading: const GradientIcon(icon: Icons.person_outline),
            title: Text(
              AppText.loginWithCreator(context),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.creatorLogin);
            },
          ),

          const Divider(),

          // About App
          ListTile(
            leading: const GradientIcon(icon: Icons.info_outline),
            title: Text(AppText.aboutApp(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.aboutApp);
            },
          ),

          // Event Collaboration Request
          ListTile(
            leading: const GradientIcon(icon: Icons.handshake_outlined),
            title: Text(
              Provider.of<LanguageProvider>(context, listen: false)
                          .currentLanguage ==
                      'en'
                  ? 'Event Collaboration Request'
                  : 'イベントコラボレーション依頼',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final url = Uri.parse(AppConstants.contactLineUrl);
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open LINE: $e')),
                  );
                }
              }
            },
          ),

          // Privacy Policy
          ListTile(
            leading: const GradientIcon(icon: Icons.privacy_tip_outlined),
            title: Text(AppText.privacyPolicy(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.privacyPolicy);
            },
          ),

          // FAQ
          ListTile(
            leading: const GradientIcon(icon: Icons.help_outline),
            title: Text(
              Provider.of<LanguageProvider>(context, listen: false)
                          .currentLanguage ==
                      'en'
                  ? 'FAQ'
                  : 'よくある質問',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()));
            },
          ),

          // Contact Us
          ListTile(
            leading: const GradientIcon(icon: Icons.email_outlined),
            title: Text(AppText.contactUs(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showContactDialog(context);
            },
          ),

          // Commercial Disclosure
          ListTile(
            leading: const GradientIcon(icon: Icons.business_outlined),
            title: Text(
              Provider.of<LanguageProvider>(context, listen: false)
                          .currentLanguage ==
                      'en'
                  ? 'Commercial Disclosure'
                  : '特定商取引法に基づく表記',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommercialDisclosureScreen(),
                ),
              );
            },
          ),

          // Cancellation Policy
          ListTile(
            leading: const GradientIcon(icon: Icons.cancel_outlined),
            title: Text(
              Provider.of<LanguageProvider>(context, listen: false)
                          .currentLanguage ==
                      'en'
                  ? 'Cancellation Policy'
                  : 'キャンセルポリシー',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CancellationPolicyScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Version
          ListTile(
            leading: const GradientIcon(icon: Icons.info),
            title: Text(AppText.version(context)),
            trailing: Text(
              AppConstants.appVersion,
              style: theme.textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.contactUs(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email
            ListTile(
              leading: const SizedBox(
                width: 34,
                height: 34,
                child: GradientIcon(
                  icon: Icons.email,
                  size: 38,
                ),
              ),
              title: Text(AppText.email(context)),
              subtitle: const Text(AppConstants.contactEmail),
              onTap: () async {
                final url = Uri(
                  scheme: 'mailto',
                  path: AppConstants.contactEmail,
                );
                try {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {
                  if (context.mounted) {
                    AppRoutes.showSnackBar(
                      context,
                      AppText.noEmailApp(context),
                      isError: true,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            // LINE
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/line.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const GradientIcon(icon: Icons.chat);
                  },
                ),
              ),
              title: Text(AppText.line(context)),
              subtitle: Text(AppText.openLine(context)),
              onTap: () async {
                final url = Uri.parse(AppConstants.contactLineUrl);
                try {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {
                  if (context.mounted) {
                    AppRoutes.showSnackBar(
                      context,
                      AppText.lineAppNotFound(context),
                      isError: true,
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => AppRoutes.goBack(context),
            child: Text(AppText.ok(context)),
          ),
        ],
      ),
    );
  }
}
