import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/api_service.dart';

class TripScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const TripScreen({super.key, required this.vehicle});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool _isTripActive = false;
  bool _isLoading = false;
  int? _tripId;
  Timer? _locationTimer;
  Timer? _uiTimer;

  double _totalDistance = 0;
  double _currentSpeed = 0;
  double _maxSpeed = 0;
  double _avgSpeed = 0;
  int _locationCount = 0;
  double _totalSpeed = 0;
  double _totalAcceleration = 0;
  int _accelCount = 0;
  double _lastSpeed = 0;
  DateTime? _tripStartTime;
  double? _lastLat;
  double? _lastLng;
  Position? _currentPosition;

  @override
  void dispose() {
    _locationTimer?.cancel();
    _uiTimer?.cancel();
    super.dispose();
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable location services')));
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission permanently denied')));
      return false;
    }
    return true;
  }

  Future<void> _startTrip() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      final result = await ApiService.startTrip(widget.vehicle['id'], position.latitude, position.longitude);
      if (result != null) {
        setState(() {
          _tripId = result['id'];
          _isTripActive = true;
          _isLoading = false;
          _tripStartTime = DateTime.now();
          _lastLat = position.latitude;
          _lastLng = position.longitude;
          _currentPosition = position;
        });
        _startLocationTracking();
        _startUiTimer();
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to start trip')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _startUiTimer() {
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        double speedKmh = position.speed * 3.6;
        if (speedKmh < 0) speedKmh = 0;
        if (_lastLat != null && _lastLng != null) {
          double dist = Geolocator.distanceBetween(_lastLat!, _lastLng!, position.latitude, position.longitude);
          _totalDistance += dist / 1000;
        }
        double acceleration = (speedKmh - _lastSpeed).abs() / 5;
        _totalAcceleration += acceleration;
        _accelCount++;
        _locationCount++;
        _totalSpeed += speedKmh;
        setState(() {
          _currentSpeed = speedKmh;
          if (speedKmh > _maxSpeed) _maxSpeed = speedKmh;
          _avgSpeed = _totalSpeed / _locationCount;
          _lastSpeed = speedKmh;
          _lastLat = position.latitude;
          _lastLng = position.longitude;
          _currentPosition = position;
        });
        if (_tripId != null) {
          await ApiService.sendLocation(_tripId!, position.latitude, position.longitude, speedKmh);
        }
      } catch (e) {
        debugPrint('Location error: $e');
      }
    });
  }

  Future<void> _endTrip() async {
    _locationTimer?.cancel();
    _uiTimer?.cancel();
    setState(() => _isLoading = true);
    double duration = 0;
    if (_tripStartTime != null) {
      duration = DateTime.now().difference(_tripStartTime!).inSeconds / 60.0;
    }
    double avgAccel = _accelCount > 0 ? _totalAcceleration / _accelCount : 0;
    final result = await ApiService.endTrip(_tripId!, _lastLat ?? 0, _lastLng ?? 0, _totalDistance, _avgSpeed, _maxSpeed, avgAccel, duration);
    setState(() => _isLoading = false);
    if (result != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF00C9A7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C9A7), size: 24),
              ),
              const SizedBox(width: 12),
              Text('Trip Complete', style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontWeight: FontWeight.w600, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _resultRow('Distance', '${_totalDistance.toStringAsFixed(2)} km'),
              _resultRow('Avg Speed', '${_avgSpeed.toStringAsFixed(1)} km/h'),
              _resultRow('Max Speed', '${_maxSpeed.toStringAsFixed(1)} km/h'),
              _resultRow('Duration', '${duration.toStringAsFixed(1)} min'),
              _resultRow('Score', '${result['efficiency_score']}'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                child: Text(result['recommendation'] ?? '', style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7AFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Done', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
          Text(value, style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDuration() {
    if (_tripStartTime == null) return '00:00';
    final diff = DateTime.now().difference(_tripStartTime!);
    final m = diff.inMinutes.toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.vehicle['vehicle_model'] ?? 'Trip', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Speed Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text(_currentSpeed.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 64, fontWeight: FontWeight.bold, color: const Color(0xFF2D7AFF))),
                  Text('km/h', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoCard('Distance', '${_totalDistance.toStringAsFixed(2)} km', const Color(0xFF2D7AFF)),
                const SizedBox(width: 12),
                _buildInfoCard('Max Speed', '${_maxSpeed.toStringAsFixed(1)} km/h', Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoCard('Avg Speed', '${_avgSpeed.toStringAsFixed(1)} km/h', const Color(0xFF00C9A7)),
                const SizedBox(width: 12),
                _buildInfoCard('Duration', _isTripActive ? _formatDuration() : '00:00', Colors.purple),
              ],
            ),
            if (_currentPosition != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF2D7AFF), size: 16),
                    const SizedBox(width: 6),
                    Text('${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_isTripActive ? _endTrip : _startTrip),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTripActive ? Colors.redAccent : const Color(0xFF2D7AFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isTripActive ? 'End Trip' : 'Start Trip', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}