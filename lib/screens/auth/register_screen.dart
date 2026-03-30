// lib/screens/auth/register_screen.dart  (USER APP)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String _error = '';

  Future<void> _register() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      await _auth.register(_emailCtrl.text, _passCtrl.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white38, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('CREATE\nACCOUNT',
                  style: GoogleFonts.bebasNeue(
                      fontSize: 44, color: Colors.white, height: 1, letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('Join the arena',
                  style: TextStyle(fontSize: 11, letterSpacing: 3, color: Colors.white38)),
              const SizedBox(height: 40),

              _label('EMAIL'),
              const SizedBox(height: 8),
              _field(controller: _emailCtrl, hint: 'you@example.com',
                  type: TextInputType.emailAddress),
              const SizedBox(height: 20),

              _label('PASSWORD'),
              const SizedBox(height: 8),
              _field(controller: _passCtrl, hint: '••••••••', obscure: true),
              const SizedBox(height: 20),

              _label('CONFIRM PASSWORD'),
              const SizedBox(height: 8),
              _field(controller: _confirmCtrl, hint: '••••••••', obscure: true),

              const SizedBox(height: 12),
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE24B4A).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_error,
                      style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 12)),
                ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text('REGISTER', style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) =>
      Text(t, style: const TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white38));

  Widget _field({required TextEditingController controller, required String hint,
      bool obscure = false, TextInputType? type}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.white38)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
