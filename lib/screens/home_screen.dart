import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() { super.initState(); _pageController = PageController(); }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E18),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
            _buildNavItem(1, Icons.bar_chart_rounded, 'Analytics'),
            _buildNavItem(2, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF6C63FF) : Colors.white24, size: 22),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}