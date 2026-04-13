import 'package:eventify/providers/auth_provider.dart';
import 'package:eventify/screens/user/cancellation_policy_screen.dart';
import 'package:eventify/screens/user/commercial_disclosure_screen.dart';
import 'package:eventify/screens/user/faq_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_text.dart';
import '../../utils/app_dialogs.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/admin_routes.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/gradient_icon.dart';

class ProfileScreenAdmin extends StatelessWidget {
  const ProfileScreenAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    // listen:false — auth state changes are handled by Consumer widgets below
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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

          // 3. Admin Dashboard / Login (replaces "Login with Creator")
          if (authProvider.isAdmin) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, AdminRoutes.adminDashboard),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.admin_panel_settings,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppText.adminDashboard(context),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(AppText.adminDashboardSubtitle(context),
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const GradientIcon(icon: Icons.logout),
              title: Text(AppText.logout(context),
                  style: TextStyle(
                      color: colorScheme.error, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final yes = await AppDialogs.confirmLogout(context);
                if (yes && context.mounted) await authProvider.logout();
              },
            ),
          ] else if (authProvider.isLoggedIn) ...[
            ListTile(
              leading: const GradientIcon(icon: Icons.admin_panel_settings),
              title: Text(AppText.loginWithAdmin(context),
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/admin-login'),
            ),
            ListTile(
              leading: const GradientIcon(icon: Icons.logout),
              title: Text(AppText.logout(context),
                  style: TextStyle(
                      color: colorScheme.error, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final yes = await AppDialogs.confirmLogout(context);
                if (yes && context.mounted) await authProvider.logout();
              },
            ),
          ] else
            ListTile(
              leading: const GradientIcon(icon: Icons.login),
              title: Text(AppText.loginWithAdmin(context),
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/admin-login'),
            ),

          // 4. Event Collaboration Request
          ListTile(
            leading: const GradientIcon(icon: Icons.handshake_outlined),
            title: Text(AppText.eventCollaboration(context),
                maxLines: 2, overflow: TextOverflow.ellipsis),
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
                context, MaterialPageRoute(builder: (_) => const FaqScreen())),
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
            title: Text(AppText.commercialDisclosure(context),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CommercialDisclosureScreen())),
          ),

          // 10. Cancellation Policy
          ListTile(
            leading: const GradientIcon(icon: Icons.cancel_outlined),
            title: Text(AppText.cancellationPolicy(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CancellationPolicyScreen())),
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
                  child: GradientIcon(icon: Icons.email, size: 38)),
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
                child: Image.asset('assets/line.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const GradientIcon(icon: Icons.chat)),
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
                'assets/whatsapp-svgrepo-com.svg',
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
              child: Text(AppText.ok(context))),
        ],
      ),
    );
  }
}
