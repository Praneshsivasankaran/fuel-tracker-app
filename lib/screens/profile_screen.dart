import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/page_transition.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadProfile(); }

  Future<void> _loadProfile() async {
    final user = await ApiService.getMe();
    setState(() { _user = user; _isLoading = false; });
  }

  Future<void> _logout() async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      content: Text('Are you sure?', style: GoogleFonts.poppins(color: Colors.white54)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white38))),
        TextButton(onPressed: () async { Navigator.pop(ctx); await ApiService.logout(); if (!mounted) return; Navigator.pushAndRemoveUntil(context, SmoothPageRoute(page: const LoginScreen()), (route) => false); },
          child: Text('Logout', style: GoogleFonts.poppins(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600))),
      ],
    ));
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A2E).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF0D0D0D), elevation: 0, automaticallyImplyLeading: false),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
              _glassCard(child: Column(children: [
                CircleAvatar(radius: 40, backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  child: Text((_user?['name'] ?? 'U')[0].toUpperCase(), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF6C63FF)))),
                const SizedBox(height: 16),
                Text(_user?['name'] ?? 'User', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(_user?['email'] ?? '', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)),
              ])),
              const SizedBox(height: 16),
              _glassCard(child: Column(children: [
                _optionTile(Icons.info_outline_rounded, 'App Version', 'v1.0.0'),
                _divider(),
                _optionTile(Icons.code_rounded, 'Built With', 'Flutter + FastAPI'),
                _divider(),
                _optionTile(Icons.psychology_rounded, 'ML Model', 'Gradient Boosting'),
                _divider(),
                _optionTile(Icons.storage_rounded, 'Database', '87 Indian Vehicles'),
              ])),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text('Logout', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
            ])),
    );
  }

  Widget _optionTile(IconData icon, String title, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(children: [
      Icon(icon, color: const Color(0xFF6C63FF), size: 22), const SizedBox(width: 14),
      Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white))),
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38)),
    ]));
  }

  Widget _divider() => Divider(height: 1, color: Colors.white.withValues(alpha: 0.06));
}