import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_text.dart';
import '../../widgets/gradient_app_bar.dart';
import 'creator_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class CreatorLoginScreen extends StatefulWidget {
  const CreatorLoginScreen({super.key});

  @override
  State<CreatorLoginScreen> createState() => _CreatorLoginScreenState();
}

class _CreatorLoginScreenState extends State<CreatorLoginScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.error(context))),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Sign in with Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // 2. Read role from Firestore users collection
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // User authenticated but has no role doc → reject
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Account not registered in app. Contact admin to add your account.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final userData = userDoc.data();
      final role = userData!['role'] as String? ?? '';

      // Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('creator_id', uid);
      await prefs.setString('creator_email', _emailController.text.trim());
      await prefs.setString('creator_role', role);

      setState(() => _isLoading = false);

      if (!mounted) return;

      // 3. Route based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      } else if (role == 'creator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CreatorDashboardScreen(),
          ),
        );
      } else {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unknown role: $role. Contact admin.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final msg = switch (e.code) {
          'user-not-found' => 'No account found for that email.',
          'wrong-password' => 'Wrong password.',
          'invalid-credential' => 'Email or password is incorrect.',
          'invalid-email' => 'Please enter a valid email address.',
          'user-disabled' => 'This account has been disabled.',
          _ => e.message ?? 'Login failed.',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            Icon(
              Icons.person_outline,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 40),
            Text(
              AppText.creatorLogin(context),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  : Text(
                      AppText.login(context),
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
