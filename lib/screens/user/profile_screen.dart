import 'package:flutter_svg/flutter_svg.dart';
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
    final isEn = context.watch<LanguageProvider>().currentLanguage == 'en';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(AppText.profile(context),
            style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),

          // 1. Language
          Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => ListTile(
              leading: const GradientIcon(icon: Icons.language),
              title: Text(AppText.language(context)),
              trailing: DropdownButton<String>(
                value: langProvider.currentLanguage,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                      value: 'en', child: Text(AppText.english(context))),
                  DropdownMenuItem(
                      value: 'ja', child: Text(AppText.japanese(context))),
                ],
                onChanged: (value) {
                  if (value != null) langProvider.switchLanguage(value);
                },
              ),
            ),
          ),

          // 2. Theme
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
              onChanged: (value) => themeProvider.toggleTheme(),
            ),
          ),

          const Divider(),

          // 3. Login with Creator
          ListTile(
            leading: const GradientIcon(icon: Icons.person_outline),
            title: Text(
              AppText.loginWithCreator(context),
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => AppRoutes.navigateTo(context, AppRoutes.creatorLogin),
          ),

          // 4. Event Collaboration Request
          ListTile(
            leading: const GradientIcon(icon: Icons.handshake_outlined),
            title: Text(
              AppText.eventCollaboration(context),
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

          // 5. Contact Us
          ListTile(
            leading: const GradientIcon(icon: Icons.email_outlined),
            title: Text(AppText.contactUs(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showContactDialog(context),
          ),

          // 6. About App
          ListTile(
            leading: const GradientIcon(icon: Icons.info_outline),
            title: Text(AppText.aboutApp(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => AppRoutes.navigateTo(context, AppRoutes.aboutApp),
          ),

          // 7. FAQ
          ListTile(
            leading: const GradientIcon(icon: Icons.help_outline),
            title: Text(AppText.faq(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaqScreen()),
            ),
          ),

          const Divider(),

          // 8. Privacy Policy
          ListTile(
            leading: const GradientIcon(icon: Icons.privacy_tip_outlined),
            title: Text(AppText.privacyPolicy(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => AppRoutes.navigateTo(context, AppRoutes.privacyPolicy),
          ),

          // 9. Commercial Disclosure
          ListTile(
            leading: const GradientIcon(icon: Icons.business_outlined),
            title: Text(
              isEn ? 'Commercial Disclosure' : '特定商取引法に基づく表記',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CommercialDisclosureScreen()),
            ),
          ),

          // 10. Cancellation Policy
          ListTile(
            leading: const GradientIcon(icon: Icons.cancel_outlined),
            title: Text(AppText.cancellationPolicy(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CancellationPolicyScreen()),
            ),
          ),

          const Divider(),

          // 11. Version
          ListTile(
            leading: const GradientIcon(icon: Icons.info),
            title: Text(AppText.version(context)),
            trailing:
                Text(AppConstants.appVersion, style: theme.textTheme.bodySmall),
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
                child: GradientIcon(icon: Icons.email, size: 38),
              ),
              title: Text(AppText.email(context)),
              subtitle: const Text(AppConstants.contactEmail),
              onTap: () async {
                final url =
                    Uri(scheme: 'mailto', path: AppConstants.contactEmail);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {
                  if (context.mounted) {
                    AppRoutes.showSnackBar(context, AppText.noEmailApp(context),
                        isError: true);
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
                  AppImages.lineLogo,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const GradientIcon(icon: Icons.chat),
                ),
              ),
              title: Text(AppText.line(context)),
              subtitle: Text(AppText.openLine(context)),
              onTap: () async {
                final url = Uri.parse(AppConstants.contactLineUrl);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {
                  if (context.mounted) {
                    AppRoutes.showSnackBar(
                        context, AppText.lineAppNotFound(context),
                        isError: true);
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            // WhatsApp
            ListTile(
              leading: SvgPicture.asset(
                AppImages.whatsappLogo,
                width: 30,
                height: 30,
              ),
              title: Text(AppText.whatsapp(context)),
              subtitle: Text(AppText.openWhatsapp(context)),
              onTap: () async {
                final url = Uri.parse(AppConstants.contactWhatsappUrl);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {
                  if (context.mounted) {
                    AppRoutes.showSnackBar(
                        context, AppText.whatsappAppNotFound(context),
                        isError: true);
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
