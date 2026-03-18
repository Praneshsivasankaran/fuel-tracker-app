import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'trip_screen.dart';
import 'add_vehicle_screen.dart';
import 'trip_map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _vehicles = [];
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final vehicles = await ApiService.getVehicles();
    final trips = await ApiService.getTrips();
    setState(() {
      _vehicles = vehicles;
      _trips = trips;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF16213E),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatCard('Vehicles', _vehicles.length.toString(), Icons.directions_car),
                        const SizedBox(width: 12),
                        _buildStatCard('Trips', _trips.length.toString(), Icons.route),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('My Vehicles', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 12),
                    if (_vehicles.isEmpty)
                      _buildEmptyCard('No vehicles yet. Tap + to add one!')
                    else
                      ..._vehicles.map((v) => _buildVehicleCard(v)),
                    const SizedBox(height: 24),
                    Text('Recent Trips', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 12),
                    if (_trips.isEmpty)
                      _buildEmptyCard('No trips recorded yet.')
                    else
                      ..._trips.map((t) => _buildTripCard(t)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
          if (result == true) _loadData();
        },
        backgroundColor: const Color(0xFF00D2FF),
        child: const Icon(Icons.add, color: Color(0xFF1A1A2E)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00D2FF), size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(dynamic vehicle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.directions_car, color: Color(0xFF00D2FF), size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle['vehicle_model'] ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('${vehicle['engine_size']}L - ${vehicle['fuel_type']}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54)),
                ],
              ),
            ),
            const Icon(Icons.play_arrow, color: Color(0xFF00D2FF), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    int score = trip['efficiency_score'] ?? 0;
    Color scoreColor = score >= 80 ? Colors.greenAccent : score >= 60 ? Colors.orangeAccent : Colors.redAccent;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripMapScreen(
              tripId: trip['id'],
              title: '${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km trip',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: scoreColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('Score: $score', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: scoreColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTripStat('Avg Speed', '${trip['avg_speed']?.toStringAsFixed(1) ?? '0'} km/h'),
                const SizedBox(width: 20),
                _buildTripStat('Max Speed', '${trip['max_speed']?.toStringAsFixed(1) ?? '0'} km/h'),
                const SizedBox(width: 20),
                _buildTripStat('Duration', '${trip['trip_duration']?.toStringAsFixed(0) ?? '0'} min'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(trip['recommendation'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38, fontStyle: FontStyle.italic)),
                ),
                const Icon(Icons.map, color: Color(0xFF00D2FF), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38)),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
      child: Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)),
    );
  }
}