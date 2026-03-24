import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/page_transition.dart';
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
  String _userName = '';

  final double _petrolPrice = 102.86;
  final double _dieselPrice = 89.39;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final vehicles = await ApiService.getVehicles();
    final trips = await ApiService.getTrips();
    final user = await ApiService.getMe();
    setState(() {
      _vehicles = vehicles;
      _trips = trips;
      _userName = user?['name'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _deleteVehicle(int vehicleId, String name) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Vehicle', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        content: Text('Delete $name and all its trips?', style: GoogleFonts.poppins(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () async { Navigator.pop(ctx); await ApiService.deleteVehicle(vehicleId); _loadData(); },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip(int tripId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Trip', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        content: Text('Delete this trip? This cannot be undone.', style: GoogleFonts.poppins(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () async { Navigator.pop(ctx); await ApiService.deleteTrip(tripId); _loadData(); },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) { return ''; }
  }

  String _estimateFuelCost(dynamic trip) {
    String rec = trip['recommendation'] ?? '';
    RegExp regex = RegExp(r'Predicted fuel: ([\d.]+)L');
    Match? match = regex.firstMatch(rec);
    if (match != null) {
      double fuel = double.tryParse(match.group(1)!) ?? 0;
      if (fuel > 0) return '~Rs ${(fuel * _petrolPrice).toStringAsFixed(0)}';
    }
    return '';
  }

  IconData _getVehicleIcon(String model) {
    String lower = model.toLowerCase();
    if (lower.contains('activa') || lower.contains('dio') || lower.contains('jupiter') || lower.contains('ntorq') || lower.contains('access') || lower.contains('burgman') || lower.contains('maestro') || lower.contains('pleasure') || lower.contains('fascino') || lower.contains('ray zr') || lower.contains('scooter')) {
      return Icons.electric_moped_rounded;
    }
    if (lower.contains('classic') || lower.contains('bullet') || lower.contains('hunter') || lower.contains('himalayan') || lower.contains('meteor') || lower.contains('shine') || lower.contains('sp 125') || lower.contains('unicorn') || lower.contains('hornet') || lower.contains('cb200') || lower.contains('pulsar') || lower.contains('dominar') || lower.contains('platina') || lower.contains('apache') || lower.contains('raider') || lower.contains('star city') || lower.contains('splendor') || lower.contains('hf deluxe') || lower.contains('glamour') || lower.contains('xtreme') || lower.contains('xpulse') || lower.contains('fz') || lower.contains('mt-15') || lower.contains('r15') || lower.contains('duke') || lower.contains('rc 200') || lower.contains('gixxer') || lower.contains('bike')) {
      return Icons.two_wheeler_rounded;
    }
    return Icons.directions_car_rounded;
  }

  Widget _fadeInWidget(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D7AFF)))
          : RefreshIndicator(
              color: const Color(0xFF2D7AFF), onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userName.isNotEmpty)
                      _fadeInWidget(Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text('Hi $_userName!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
                      ), 0),
                    _fadeInWidget(Container(
                      width: double.infinity, padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2D7AFF), Color(0xFF00C9A7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 32),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Today's Fuel Prices (Chennai)", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Text('Petrol: Rs ${_petrolPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(width: 16),
                                Text('Diesel: Rs ${_dieselPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                              ]),
                            ]),
                          ),
                        ],
                      ),
                    ), 1),
                    const SizedBox(height: 16),
                    _fadeInWidget(Row(children: [
                      _buildStatCard('Vehicles', _vehicles.length.toString(), Icons.directions_car_rounded, const Color(0xFF2D7AFF)),
                      const SizedBox(width: 12),
                      _buildStatCard('Trips', _trips.length.toString(), Icons.route_rounded, const Color(0xFF00C9A7)),
                    ]), 2),
                    const SizedBox(height: 24),
                    Text('My Vehicles', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Text('Long press to delete', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (_vehicles.isEmpty) _fadeInWidget(_buildEmptyCard('No vehicles yet. Tap + to add one!'), 3)
                    else ..._vehicles.asMap().entries.map((e) => _fadeInWidget(_buildVehicleCard(e.value), 3 + e.key)),
                    const SizedBox(height: 24),
                    Text('Recent Trips', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Text('Tap for map • Long press to delete', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (_trips.isEmpty) _fadeInWidget(_buildEmptyCard('No trips recorded yet.'), 4)
                    else ..._trips.asMap().entries.map((e) => _fadeInWidget(_buildTripCard(e.value), 4 + e.key)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, SmoothPageRoute(page: const AddVehicleScreen()));
          if (result == true) _loadData();
        },
        backgroundColor: const Color(0xFF2D7AFF), elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildVehicleCard(dynamic vehicle) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context, SmoothPageRoute(page: TripScreen(vehicle: vehicle)));
        if (result == true) _loadData();
      },
      onLongPress: () => _deleteVehicle(vehicle['id'], vehicle['vehicle_model'] ?? 'this vehicle'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF2D7AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_getVehicleIcon(vehicle['vehicle_model'] ?? ''), color: const Color(0xFF2D7AFF), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vehicle['vehicle_model'] ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
            Text('${vehicle['engine_size']}L • ${vehicle['fuel_type']}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          ])),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF00C9A7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00C9A7), size: 22),
          ),
        ]),
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    int score = trip['efficiency_score'] ?? 0;
    Color scoreColor = score >= 80 ? const Color(0xFF00C9A7) : score >= 60 ? Colors.orange : Colors.redAccent;
    String dateStr = _formatDate(trip['start_time']?.toString());
    String fuelCost = _estimateFuelCost(trip);
    return GestureDetector(
      onTap: () => Navigator.push(context, SmoothPageRoute(page: TripMapScreen(tripId: trip['id'], title: '${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km trip'))),
      onLongPress: () => _deleteTrip(trip['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
              if (dateStr.isNotEmpty) Text(dateStr, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Score: $score', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: scoreColor)),
              ),
              if (fuelCost.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(fuelCost, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D7AFF)))),
            ]),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _buildTripStat('Avg Speed', '${trip['avg_speed']?.toStringAsFixed(1) ?? '0'} km/h'),
            const SizedBox(width: 20),
            _buildTripStat('Max Speed', '${trip['max_speed']?.toStringAsFixed(1) ?? '0'} km/h'),
            const SizedBox(width: 20),
            _buildTripStat('Duration', '${trip['trip_duration']?.toStringAsFixed(0) ?? '0'} min'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text(trip['recommendation'] ?? '', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.map_rounded, color: Color(0xFF2D7AFF), size: 20),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTripStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
    );
  }
}