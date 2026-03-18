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
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final data = await ApiService.getAnalytics();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF16213E),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
          : _data == null || _data!['total_trips'] == 0
              ? Center(
                  child: Text(
                    'No trip data yet.\nStart driving to see analytics!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white54),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSummaryCard('Total Trips', '${_data!['total_trips']}', Icons.route),
                          const SizedBox(width: 12),
                          _buildSummaryCard('Total Distance', '${_data!['total_distance']} km', Icons.straighten),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSummaryCard('Avg Speed', '${_data!['avg_speed']} km/h', Icons.speed),
                          const SizedBox(width: 12),
                          _buildSummaryCard('Avg Score', '${_data!['avg_efficiency']}', Icons.star),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSummaryCard('Max Speed', '${_data!['max_speed_ever']} km/h', Icons.flash_on),
                          const SizedBox(width: 12),
                          _buildSummaryCard('Total Time', '${_data!['total_duration']} min', Icons.timer),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Efficiency Score Trend', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
                        child: _buildEfficiencyChart(),
                      ),
                      const SizedBox(height: 24),
                      Text('Speed per Trip', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
                        child: _buildSpeedChart(),
                      ),
                      const SizedBox(height: 24),
                      Text('Distance per Trip', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
                        child: _buildDistanceChart(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF00D2FF), size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyChart() {
    List tripsData = _data!['trips_data'] ?? [];
    if (tripsData.isEmpty) return const SizedBox();

    List<FlSpot> spots = [];
    for (int i = 0; i < tripsData.length; i++) {
      spots.add(FlSpot(i.toDouble(), (tripsData[i]['efficiency_score'] ?? 0).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) {
            return Text('${value.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 10));
          })),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            return Text('T${value.toInt() + 1}', style: const TextStyle(color: Colors.white38, fontSize: 10));
          })),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF00D2FF),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF00D2FF).withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChart() {
    List tripsData = _data!['trips_data'] ?? [];
    if (tripsData.isEmpty) return const SizedBox();

    List<BarChartGroupData> bars = [];
    for (int i = 0; i < tripsData.length; i++) {
      bars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: (tripsData[i]['avg_speed'] ?? 0).toDouble(),
          color: const Color(0xFF00D2FF),
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ]));
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) {
            return Text('${value.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 10));
          })),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            return Text('T${value.toInt() + 1}', style: const TextStyle(color: Colors.white38, fontSize: 10));
          })),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: bars,
      ),
    );
  }

  Widget _buildDistanceChart() {
    List tripsData = _data!['trips_data'] ?? [];
    if (tripsData.isEmpty) return const SizedBox();

    List<BarChartGroupData> bars = [];
    for (int i = 0; i < tripsData.length; i++) {
      bars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: (tripsData[i]['distance'] ?? 0).toDouble(),
          color: Colors.greenAccent,
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ]));
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) {
            return Text('${value.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 10));
          })),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            return Text('T${value.toInt() + 1}', style: const TextStyle(color: Colors.white38, fontSize: 10));
          })),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: bars,
      ),
    );
  }
}