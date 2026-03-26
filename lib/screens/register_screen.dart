import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/page_transition.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) { setState(() => _errorMessage = 'Passwords do not match'); return; }
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) { setState(() => _errorMessage = 'All fields are required'); return; }
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await ApiService.register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Account created! Please login.'), backgroundColor: const Color(0xFF00E5A0), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      Navigator.pushReplacement(context, SmoothPageRoute(page: const LoginScreen()));
    } else { setState(() => _errorMessage = result['message']); }
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, bool obscure) {
    return TextField(
      controller: controller, style: GoogleFonts.poppins(color: Colors.white), obscureText: obscure,
      decoration: InputDecoration(
        labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true, fillColor: const Color(0xFF12121C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3))),
              child: const Icon(Icons.person_add, size: 64, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 24),
            Text('Create Account', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Join Fuel Tracker today', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)),
            const SizedBox(height: 32),
            _buildField(_nameController, 'Full Name', Icons.person_outline, false),
            const SizedBox(height: 14),
            _buildField(_emailController, 'Email', Icons.email_outlined, false),
            const SizedBox(height: 14),
            _buildField(_passwordController, 'Password', Icons.lock_outline, true),
            const SizedBox(height: 14),
            _buildField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, true),
            const SizedBox(height: 12),
            if (_errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 14))),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A0), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)) : Text('Register', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context, SmoothPageRoute(page: const LoginScreen())),
              child: RichText(text: TextSpan(text: 'Already have an account? ', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14), children: [TextSpan(text: 'Login', style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.w600))])),
            ),
          ]),
        ),
      ),
    );
  }
}