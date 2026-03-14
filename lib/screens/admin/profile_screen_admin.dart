import 'package:eventify/providers/auth_provider.dart';
import 'package:eventify/screens/user/cancellation_policy_screen.dart';
import 'package:eventify/screens/user/commercial_disclosure_screen.dart';
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

class ProfileScreenAdmin extends StatelessWidget {
  const ProfileScreenAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch language provider to rebuild when language changes
    context.watch<LanguageProvider>();
    final authProvider = Provider.of<AuthProvider>(context);

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

          // ── Admin Access Section ──────────────────────────────────────────
          // Case 1: Logged in AS admin → show dashboard button + logout
          if (authProvider.isAdmin) ...[
            // Admin Dashboard — prominent button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/admin-dashboard'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppText.adminDashboard(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppText.adminDashboardSubtitle(context),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const GradientIcon(icon: Icons.logout),
              title: Text(
                AppText.logout(context),
                style: TextStyle(
                    color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppText.logout(context)),
                    content: Text(AppText.confirmLogout(context)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(AppText.no(context))),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(AppText.yes(context))),
                    ],
                  ),
                );
                if (yes == true && context.mounted) {
                  await authProvider.logout();
                }
              },
            ),
          ]
          // Case 2: Logged in but NOT admin → show "Login as Admin" + Logout
          else if (authProvider.isLoggedIn) ...[
            ListTile(
              leading: const GradientIcon(icon: Icons.admin_panel_settings),
              title: Text(
                AppText.loginWithAdmin(context),
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/admin-login'),
            ),
            ListTile(
              leading: const GradientIcon(icon: Icons.logout),
              title: Text(
                AppText.logout(context),
                style: TextStyle(
                    color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppText.logout(context)),
                    content: Text(AppText.confirmLogout(context)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(AppText.no(context))),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(AppText.yes(context))),
                    ],
                  ),
                );
                if (yes == true && context.mounted) {
                  await authProvider.logout();
                }
              },
            ),
          ]
          // Case 3: Not logged in → just "Login as Admin"
          else
            ListTile(
              leading: const GradientIcon(icon: Icons.login),
              title: Text(
                AppText.loginWithAdmin(context),
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/admin-login'),
            ),

          const Divider(),

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

          // Privacy Policy
          ListTile(
            leading: const GradientIcon(icon: Icons.privacy_tip_outlined),
            title: Text(AppText.privacyPolicy(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.privacyPolicy);
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
              AppText.commercialDisclosure(context),
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
            title: Text(AppText.cancellationPolicy(context)),
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
