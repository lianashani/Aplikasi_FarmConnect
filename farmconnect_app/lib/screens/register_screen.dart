import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'nav/farmer_nav.dart';
import 'nav/buyer_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

import 'package:flutter/material.dart';
class _RegisterScreenState extends State<RegisterScreen> {
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/auth_provider.dart';
  import 'nav/farmer_nav.dart';
  import 'nav/buyer_nav.dart';

  class RegisterScreen extends StatefulWidget {
    const RegisterScreen({super.key});

    @override
    State<RegisterScreen> createState() => _RegisterScreenState();
  }

  class _RegisterScreenState extends State<RegisterScreen> {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool loading = false;
    String role = 'pembeli';

    Future<void> _register() async {
      setState(() => loading = true);
      try {
        await context.read<AuthProvider>().register(
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passCtrl.text,
          role: role,
        );
        if (!mounted) return;
        final userRole = context.read<AuthProvider>().role;
        if (userRole == 'farmer' || userRole == 'petani') {
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
          SnackBar(content: Text('Register gagal: $e')),
        );
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Akun')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Pilih Peran', style: Theme.of(context).textTheme.titleMedium),
              ),
              RadioListTile<String>(
                value: 'petani',
                groupValue: role,
                onChanged: loading ? null : (v) => setState(() => role = v ?? 'pembeli'),
                title: const Text('Petani'),
              ),
              RadioListTile<String>(
                value: 'pembeli',
                groupValue: role,
                onChanged: loading ? null : (v) => setState(() => role = v ?? 'pembeli'),
                title: const Text('Pembeli'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _register,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
