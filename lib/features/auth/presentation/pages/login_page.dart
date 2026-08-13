import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Success/Error হলে one-time side-effect (navigate / snackbar) —
    // এজন্য listen ব্যবহার হয়, watch না।
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('লগইন করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
