import 'package:eventify/config/admin_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_text.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_app_bar.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(AppText.error(context))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use AuthProvider's login method
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Check if user is admin
      if (!authProvider.isAdmin) {
        await authProvider.logout();
        if (!mounted) return;
        setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(AppText.adminAccessOnly(context)),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      // FIX L-16: Navigate to home wrapper (has bottom nav) not dashboard directly
      navigator.pushReplacementNamed(AdminRoutes.home);
    } catch (e) {
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<LanguageProvider>();
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(AppText.adminLoginTitle(context),
            style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings,
                  size: 100, color: Theme.of(context).primaryColor),
              const SizedBox(height: 40),
              Text(AppText.adminPortal(context),
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppText.email(context),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppText.password(context),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isLoading ? null : _login(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Text(AppText.login(context),
                        style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
