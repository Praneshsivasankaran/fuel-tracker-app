import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
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
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final vehicles = await ApiService.getVehicles();
    final trips = await ApiService.getTrips();
    setState(() { _vehicles = vehicles; _trips = trips; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D7AFF)))
          : RefreshIndicator(
              color: const Color(0xFF2D7AFF),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatCard('Vehicles', _vehicles.length.toString(), Icons.directions_car_rounded, const Color(0xFF2D7AFF)),
                        const SizedBox(width: 12),
                        _buildStatCard('Trips', _trips.length.toString(), Icons.route_rounded, const Color(0xFF00C9A7)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('My Vehicles', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    if (_vehicles.isEmpty) _buildEmptyCard('No vehicles yet. Tap + to add one!')
                    else ..._vehicles.map((v) => _buildVehicleCard(v)),
                    const SizedBox(height: 24),
                    Text('Recent Trips', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    if (_trips.isEmpty) _buildEmptyCard('No trips recorded yet.')
                    else ..._trips.map((t) => _buildTripCard(t)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
          if (result == true) _loadData();
        },
        backgroundColor: const Color(0xFF2D7AFF),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
                Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(dynamic vehicle) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripScreen(vehicle: vehicle))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF2D7AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2D7AFF), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle['vehicle_model'] ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                  Text('${vehicle['engine_size']}L • ${vehicle['fuel_type']}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF00C9A7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00C9A7), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    int score = trip['efficiency_score'] ?? 0;
    Color scoreColor = score >= 80 ? const Color(0xFF00C9A7) : score >= 60 ? Colors.orange : Colors.redAccent;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripMapScreen(tripId: trip['id'], title: '${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km trip'))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Score: $score', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: scoreColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTripStat('Avg Speed', '${trip['avg_speed']?.toStringAsFixed(1) ?? '0'} km/h'),
                const SizedBox(width: 20),
                _buildTripStat('Max Speed', '${trip['max_speed']?.toStringAsFixed(1) ?? '0'} km/h'),
                const SizedBox(width: 20),
                _buildTripStat('Duration', '${trip['trip_duration']?.toStringAsFixed(0) ?? '0'} min'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text(trip['recommendation'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))),
                const Icon(Icons.map_rounded, color: Color(0xFF2D7AFF), size: 20),
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
        Text(value, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
    );
  }
}