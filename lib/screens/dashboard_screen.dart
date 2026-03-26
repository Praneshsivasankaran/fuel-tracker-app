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
    if (!mounted) return;
    setState(() => _isLoading = true);
    final vehicles = await ApiService.getVehicles();
    final trips = await ApiService.getTrips();
    final user = await ApiService.getMe();
    if (!mounted) return;
    setState(() { _vehicles = vehicles; _trips = trips; _userName = user?['name'] ?? ''; _isLoading = false; });
  }

  Future<void> _deleteVehicle(int vehicleId, String name) async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF12121C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Vehicle', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      content: Text('Delete $name and all its trips?', style: GoogleFonts.poppins(color: Colors.white54)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white38))),
        TextButton(onPressed: () async { Navigator.pop(ctx); await ApiService.deleteVehicle(vehicleId); _loadData(); }, child: Text('Delete', style: GoogleFonts.poppins(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600))),
      ],
    ));
  }

  Future<void> _deleteTrip(int tripId) async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF12121C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Trip', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      content: Text('Delete this trip?', style: GoogleFonts.poppins(color: Colors.white54)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white38))),
        TextButton(onPressed: () async { Navigator.pop(ctx); await ApiService.deleteTrip(tripId); _loadData(); }, child: Text('Delete', style: GoogleFonts.poppins(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600))),
      ],
    ));
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try { final d = DateTime.parse(dateStr); final m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]}, ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; } catch (e) { return ''; }
  }

  String _estimateFuelCost(dynamic trip) {
    String rec = trip['recommendation'] ?? '';
    RegExp regex = RegExp(r'Predicted fuel: ([\d.]+)L');
    Match? match = regex.firstMatch(rec);
    if (match != null) { double fuel = double.tryParse(match.group(1)!) ?? 0; if (fuel > 0) return '₹${(fuel * _petrolPrice).toStringAsFixed(0)}'; }
    return '';
  }

  IconData _getVehicleIcon(String model) {
    String l = model.toLowerCase();
    if (l.contains('activa') || l.contains('dio') || l.contains('jupiter') || l.contains('ntorq') || l.contains('access') || l.contains('burgman') || l.contains('maestro') || l.contains('pleasure') || l.contains('fascino') || l.contains('ray zr')) return Icons.electric_moped_rounded;
    if (l.contains('classic') || l.contains('bullet') || l.contains('hunter') || l.contains('himalayan') || l.contains('meteor') || l.contains('shine') || l.contains('sp 125') || l.contains('unicorn') || l.contains('hornet') || l.contains('cb200') || l.contains('pulsar') || l.contains('dominar') || l.contains('platina') || l.contains('apache') || l.contains('raider') || l.contains('star city') || l.contains('splendor') || l.contains('hf deluxe') || l.contains('glamour') || l.contains('xtreme') || l.contains('xpulse') || l.contains('fz') || l.contains('mt-15') || l.contains('r15') || l.contains('duke') || l.contains('rc 200') || l.contains('gixxer')) return Icons.two_wheeler_rounded;
    return Icons.directions_car_rounded;
  }

  Widget _fadeInWidget(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0), duration: Duration(milliseconds: 400 + (index * 100)), curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding, EdgeInsets? margin}) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121C).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF0A0A0F), elevation: 0, automaticallyImplyLeading: false),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(color: const Color(0xFF6C63FF), onRefresh: _loadData,
              child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_userName.isNotEmpty) _fadeInWidget(Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('Hi $_userName! 👋', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))), 0),
                  _fadeInWidget(Container(
                    width: double.infinity, padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00E5A0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Today's Fuel Prices", style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text('⛽ ₹${_petrolPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                          const SizedBox(width: 10),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text('🛢 ₹${_dieselPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                        ]),
                      ])),
                    ]),
                  ), 1),
                  const SizedBox(height: 16),
                  _fadeInWidget(Row(children: [
                    _buildStatCard('Vehicles', _vehicles.length.toString(), Icons.directions_car_rounded, const Color(0xFF6C63FF)),
                    const SizedBox(width: 12),
                    _buildStatCard('Trips', _trips.length.toString(), Icons.route_rounded, const Color(0xFF00E5A0)),
                  ]), 2),
                  const SizedBox(height: 24),
                  Text('My Vehicles', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('Long press to delete', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white24)),
                  const SizedBox(height: 8),
                  if (_vehicles.isEmpty) _fadeInWidget(_glassCard(child: Center(child: Text('No vehicles yet. Tap + to add one!', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)))), 3)
                  else ..._vehicles.asMap().entries.map((e) => _fadeInWidget(_buildVehicleCard(e.value), 3 + e.key)),
                  const SizedBox(height: 24),
                  Text('Recent Trips', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('Tap for map • Long press to delete', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white24)),
                  const SizedBox(height: 8),
                  if (_trips.isEmpty) _fadeInWidget(_glassCard(child: Center(child: Text('No trips recorded yet.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)))), 4)
                  else ..._trips.asMap().entries.map((e) => _fadeInWidget(_buildTripCard(e.value), 4 + e.key)),
                ]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { final result = await Navigator.push(context, SmoothPageRoute(page: const AddVehicleScreen())); if (result == true) _loadData(); },
        backgroundColor: const Color(0xFF6C63FF), elevation: 4, child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(child: _glassCard(padding: const EdgeInsets.all(18), child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38)),
      ]),
    ])));
  }

  Widget _buildVehicleCard(dynamic vehicle) {
    return GestureDetector(
      onTap: () async { final result = await Navigator.push(context, SmoothPageRoute(page: TripScreen(vehicle: vehicle))); if (result == true) _loadData(); },
      onLongPress: () => _deleteVehicle(vehicle['id'], vehicle['vehicle_model'] ?? 'vehicle'),
      child: _glassCard(margin: const EdgeInsets.only(bottom: 10), child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(_getVehicleIcon(vehicle['vehicle_model'] ?? ''), color: const Color(0xFF6C63FF), size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(vehicle['vehicle_model'] ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          Text('${vehicle['engine_size']}L • ${vehicle['fuel_type']}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38)),
        ])),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF00E5A0).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00E5A0), size: 22)),
      ])),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    int score = trip['efficiency_score'] ?? 0;
    Color scoreColor = score >= 80 ? const Color(0xFF00E5A0) : score >= 60 ? const Color(0xFFFFB800) : const Color(0xFFFF6B6B);
    String dateStr = _formatDate(trip['start_time']?.toString());
    String fuelCost = _estimateFuelCost(trip);
    return GestureDetector(
      onTap: () => Navigator.push(context, SmoothPageRoute(page: TripMapScreen(tripId: trip['id'], title: '${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km trip'))),
      onLongPress: () => _deleteTrip(trip['id']),
      child: _glassCard(margin: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${trip['total_distance']?.toStringAsFixed(1) ?? '0'} km', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            if (dateStr.isNotEmpty) Text(dateStr, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white30)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text('$score', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: scoreColor))),
            if (fuelCost.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(fuelCost, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6C63FF)))),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _buildTripStat('Avg', '${trip['avg_speed']?.toStringAsFixed(0) ?? '0'} km/h'),
          const SizedBox(width: 16),
          _buildTripStat('Max', '${trip['max_speed']?.toStringAsFixed(0) ?? '0'} km/h'),
          const SizedBox(width: 16),
          _buildTripStat('Time', '${trip['trip_duration']?.toStringAsFixed(0) ?? '0'} min'),
        ]),
      ])),
    );
  }

  Widget _buildTripStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white24)),
    ]);
  }
}