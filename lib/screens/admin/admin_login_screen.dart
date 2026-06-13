import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/songs_provider.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<SongsProvider>().checkPassword(_passwordCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      setState(() => _error = 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin Login', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, color: Color(0xFF81C784), size: 72),
            const SizedBox(height: 16),
            const Text('Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter your admin password to continue.',
                style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.lock, color: Colors.white38),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white38),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                errorText: _error,
                filled: true,
                fillColor: const Color(0xFF1A2E1B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF81C784), width: 2)),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Default password: admin123',
                style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
