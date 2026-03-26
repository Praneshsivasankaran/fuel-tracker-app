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
    if (!mounted) return;
    setState(() { _data = data; _isLoading = false; });
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF12121C).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(title: Text('Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF0A0A0F), elevation: 0, automaticallyImplyLeading: false),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _data == null || _data!['total_trips'] == 0
              ? Center(child: Text('No trip data yet.\nStart driving to see analytics!', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white38)))
              : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00E5A0)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Driving Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 16),
                      Row(children: [_summaryItem('Trips', '${_data!['total_trips']}'), _summaryItem('Distance', '${_data!['total_distance']} km'), _summaryItem('Time', '${_data!['total_duration']} min')]),
                      const SizedBox(height: 12),
                      Row(children: [_summaryItem('Avg Speed', '${_data!['avg_speed']} km/h'), _summaryItem('Top Speed', '${_data!['max_speed_ever']} km/h'), _summaryItem('Avg Score', '${_data!['avg_efficiency']}')]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.route_rounded, color: const Color(0xFF6C63FF), size: 20),
                      const SizedBox(height: 8),
                      Text('${_data!['total_trips']}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Trips', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38)),
                    ]))),
                    const SizedBox(width: 12),
                    Expanded(child: _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.speed_rounded, color: const Color(0xFF00E5A0), size: 20),
                      const SizedBox(height: 8),
                      Text('${_data!['avg_speed']}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Avg km/h', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38)),
                    ]))),
                  ]),
                  const SizedBox(height: 24),
                  _chartCard('Efficiency Trend', _buildEfficiencyChart()),
                  const SizedBox(height: 16),
                  _chartCard('Speed per Trip', _buildSpeedChart()),
                  const SizedBox(height: 16),
                  _chartCard('Distance per Trip', _buildDistanceChart()),
                ])),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(child: Column(children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
    ]));
  }

  Widget _chartCard(String title, Widget chart) {
    return _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      const SizedBox(height: 16),
      SizedBox(height: 180, child: chart),
    ]));
  }

  Widget _buildEfficiencyChart() {
    List t = _data!['trips_data'] ?? []; if (t.isEmpty) return const SizedBox();
    List<FlSpot> spots = []; for (int i = 0; i < t.length; i++) spots.add(FlSpot(i.toDouble(), (t[i]['efficiency_score'] ?? 0).toDouble()));
    return LineChart(LineChartData(gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: Colors.white24, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('T${v.toInt()+1}', style: const TextStyle(color: Colors.white24, fontSize: 10)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
      borderData: FlBorderData(show: false), minY: 0, maxY: 100,
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: const Color(0xFF6C63FF), barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0xFF6C63FF).withValues(alpha: 0.1)))],
    ));
  }

  Widget _buildSpeedChart() {
    List t = _data!['trips_data'] ?? []; if (t.isEmpty) return const SizedBox();
    List<BarChartGroupData> bars = []; for (int i = 0; i < t.length; i++) bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (t[i]['avg_speed'] ?? 0).toDouble(), color: const Color(0xFF6C63FF), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]));
    return BarChart(BarChartData(gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: Colors.white24, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('T${v.toInt()+1}', style: const TextStyle(color: Colors.white24, fontSize: 10)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
      borderData: FlBorderData(show: false), barGroups: bars));
  }

  Widget _buildDistanceChart() {
    List t = _data!['trips_data'] ?? []; if (t.isEmpty) return const SizedBox();
    List<BarChartGroupData> bars = []; for (int i = 0; i < t.length; i++) bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (t[i]['distance'] ?? 0).toDouble(), color: const Color(0xFF00E5A0), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]));
    return BarChart(BarChartData(gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: Colors.white24, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('T${v.toInt()+1}', style: const TextStyle(color: Colors.white24, fontSize: 10)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
      borderData: FlBorderData(show: false), barGroups: bars));
  }
}