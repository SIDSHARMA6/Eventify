import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_text.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../config/admin_routes.dart';
import 'creator_dashboard_screen.dart';

class CreatorLoginScreen extends StatefulWidget {
  const CreatorLoginScreen({super.key});

  @override
  State<CreatorLoginScreen> createState() => _CreatorLoginScreenState();
}

class _CreatorLoginScreenState extends State<CreatorLoginScreen> {
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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.error(context))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (authProvider.isAdmin) {
        // FIX L-37: Navigate to admin home wrapper (has bottom nav) not dashboard directly
        Navigator.pushReplacementNamed(context, AdminRoutes.home);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CreatorDashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      final msg = e.toString().contains('Unauthorized')
          ? 'Unknown role. Contact admin.'
          : e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<LanguageProvider>();
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.creatorLogin(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.person_outline,
                size: 100, color: Theme.of(context).primaryColor),
            const SizedBox(height: 40),
            Text(
              AppText.creatorLogin(context),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
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
                  padding: const EdgeInsets.symmetric(vertical: 16)),
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
    );
  }
}
