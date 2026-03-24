import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadAnalytics(); }

  Future<void> _loadAnalytics() async {
    final data = await ApiService.getAnalytics();
    setState(() { _data = data; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D7AFF)))
          : _data == null || _data!['total_trips'] == 0
              ? Center(child: Text('No trip data yet.\nStart driving to see analytics!', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driving Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2D7AFF), Color(0xFF00C9A7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driving Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                            const SizedBox(height: 16),
                            Row(children: [
                              _buildSummaryItem('Total Trips', '${_data!['total_trips']}'),
                              _buildSummaryItem('Distance', '${_data!['total_distance']} km'),
                              _buildSummaryItem('Drive Time', '${_data!['total_duration']} min'),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              _buildSummaryItem('Avg Speed', '${_data!['avg_speed']} km/h'),
                              _buildSummaryItem('Top Speed', '${_data!['max_speed_ever']} km/h'),
                              _buildSummaryItem('Avg Score', '${_data!['avg_efficiency']}'),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        _buildStatCard('Total Trips', '${_data!['total_trips']}', Icons.route_rounded, const Color(0xFF2D7AFF)),
                        const SizedBox(width: 12),
                        _buildStatCard('Distance', '${_data!['total_distance']} km', Icons.straighten_rounded, const Color(0xFF00C9A7)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        _buildStatCard('Avg Speed', '${_data!['avg_speed']} km/h', Icons.speed_rounded, Colors.orange),
                        const SizedBox(width: 12),
                        _buildStatCard('Avg Score', '${_data!['avg_efficiency']}', Icons.star_rounded, const Color(0xFFFFB800)),
                      ]),
                      const SizedBox(height: 24),
                      _buildChartCard('Efficiency Score Trend', _buildEfficiencyChart()),
                      const SizedBox(height: 16),
                      _buildChartCard('Speed per Trip', _buildSpeedChart()),
                      const SizedBox(height: 16),
                      _buildChartCard('Distance per Trip', _buildDistanceChart()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
      ]),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        const SizedBox(height: 16),
        SizedBox(height: 180, child: chart),
      ]),
    );
  }

  Widget _buildEfficiencyChart() {
    List tripsData = _data!['trips_data'] ?? [];
    if (tripsData.isEmpty) return const SizedBox();
    List<FlSpot> spots = [];
    for (int i = 0; i < tripsData.length; i++) {
      spots.add(FlSpot(i.toDouble(), (tripsData[i]['efficiency_score'] ?? 0).toDouble()));
    }
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('T${v.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minY: 0, maxY: 100,
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: const Color(0xFF2D7AFF), barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0xFF2D7AFF).withValues(alpha: 0.1)))],
    ));
  }

  Widget _buildSpeedChart() {
    List tripsData = _data!['trips_data'] ?? [];
    if (tripsData.isEmpty) return const SizedBox();
    List<BarChartGroupData> bars = [];
    for (int i = 0; i < tripsData.length; i++) {
      bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (tripsData[i]['avg_speed'] ?? 0).toDouble(), color: const Color(0xFF2D7AFF), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]));
    }
    return BarChart(BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('T${v.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: bars,
    ));
  }

  Widget _buildDistanceChart() {
    List tripsData = _data!['trips_data'] ?? [];
    if (tripsData.isEmpty) return const SizedBox();
    List<BarChartGroupData> bars = [];
    for (int i = 0; i < tripsData.length; i++) {
      bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (tripsData[i]['distance'] ?? 0).toDouble(), color: const Color(0xFF00C9A7), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]));
    }
    return BarChart(BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('T${v.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: bars,
    ));
  }
}