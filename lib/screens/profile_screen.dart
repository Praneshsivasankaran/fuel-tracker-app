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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, SmoothPageRoute(page: const LoginScreen()), (route) => false);
            },
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D7AFF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                    child: Column(children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF2D7AFF).withValues(alpha: 0.1),
                        child: Text((_user?['name'] ?? 'U')[0].toUpperCase(), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF2D7AFF))),
                      ),
                      const SizedBox(height: 16),
                      Text(_user?['name'] ?? 'User', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text(_user?['email'] ?? '', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Settings-style options
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                    child: Column(children: [
                      _buildOptionTile(Icons.info_outline_rounded, 'App Version', 'v1.0.0'),
                      _buildDivider(),
                      _buildOptionTile(Icons.code_rounded, 'Built With', 'Flutter + FastAPI'),
                      _buildDivider(),
                      _buildOptionTile(Icons.psychology_rounded, 'ML Model', 'Gradient Boosting'),
                      _buildDivider(),
                      _buildOptionTile(Icons.storage_rounded, 'Database', '87 Indian Vehicles'),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text('Logout', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF2D7AFF), size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E)))),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 52);
  }
}