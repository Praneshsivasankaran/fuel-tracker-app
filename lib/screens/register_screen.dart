import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
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
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'All fields are required');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await ApiService.register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.'), backgroundColor: Color(0xFF00C9A7)));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, bool obscure) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E)),
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF2D7AFF)),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2D7AFF), width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF2D7AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.person_add, size: 64, color: Color(0xFF2D7AFF)),
              ),
              const SizedBox(height: 24),
              Text('Create Account', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              Text('Join Fuel Tracker today', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),
              _buildField(_nameController, 'Full Name', Icons.person_outline, false),
              const SizedBox(height: 14),
              _buildField(_emailController, 'Email', Icons.email_outlined, false),
              const SizedBox(height: 14),
              _buildField(_passwordController, 'Password', Icons.lock_outline, true),
              const SizedBox(height: 14),
              _buildField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, true),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14))),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7AFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Register', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: RichText(
                  text: TextSpan(text: 'Already have an account? ', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                    children: [TextSpan(text: 'Login', style: GoogleFonts.poppins(color: const Color(0xFF2D7AFF), fontWeight: FontWeight.w600))]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}