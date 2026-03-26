import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/page_transition.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await ApiService.login(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (result['success']) {
      if (!mounted) return;
      Navigator.pushReplacement(context, SmoothPageRoute(page: const HomeScreen()));
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.local_gas_station, size: 64, color: Color(0xFF6C63FF)),
              ),
              const SizedBox(height: 24),
              Text('Welcome Back', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Sign in to continue', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)),
              const SizedBox(height: 40),
              _buildTextField(_emailController, 'Email', Icons.email_outlined, false),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', Icons.lock_outline, true),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 14))),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A0), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                      : Text('Login', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, SmoothPageRoute(page: const RegisterScreen())),
                child: RichText(
                  text: TextSpan(text: "Don't have an account? ", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
                    children: [TextSpan(text: 'Register', style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.w600))]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool obscure) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: const Color(0xFF12121C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
      ),
      keyboardType: obscure ? null : TextInputType.emailAddress,
    );
  }
}