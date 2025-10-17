import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'nav/farmer_nav.dart';
import 'nav/buyer_nav.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/auth_provider.dart';
  import 'nav/farmer_nav.dart';
  import 'nav/buyer_nav.dart';
  import 'register_screen.dart';

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool loading = false;

    Future<void> _login() async {
      setState(() => loading = true);
      try {
        await context.read<AuthProvider>().login(emailCtrl.text.trim(), passCtrl.text);
        if (!mounted) return;
        final role = context.read<AuthProvider>().role;
        if (role == 'farmer' || role == 'petani') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const FarmerNav()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const BuyerNav()),
            (route) => false,
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Masuk'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Belum punya akun? Daftar'),
              )
            ],
          ),
        ),
      );
    }
  }
