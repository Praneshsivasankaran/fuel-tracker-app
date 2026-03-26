import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';

class TripMapScreen extends StatefulWidget {
  final int tripId; final String title;
  const TripMapScreen({super.key, required this.tripId, required this.title});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  GoogleMapController? _mapController; Set<Polyline> _polylines = {}; Set<Marker> _markers = {};
  bool _isLoading = true; LatLng _center = const LatLng(13.0827, 80.2707);

  @override
  void initState() { super.initState(); _loadRoute(); }

  Future<void> _loadRoute() async {
    final data = await ApiService.getTripRoute(widget.tripId);
    if (data != null) {
      List<LatLng> points = [];
      double sLat = data['start_lat'] ?? 0, sLng = data['start_lng'] ?? 0, eLat = data['end_lat'] ?? 0, eLng = data['end_lng'] ?? 0;
      if (sLat != 0 && sLng != 0) points.add(LatLng(sLat, sLng));
      for (var loc in (data['locations'] ?? [])) points.add(LatLng(loc['latitude'], loc['longitude']));
      if (eLat != 0 && eLng != 0) points.add(LatLng(eLat, eLng));
      Set<Marker> markers = {};
      if (points.isNotEmpty) { markers.add(Marker(markerId: const MarkerId('start'), position: points.first, infoWindow: const InfoWindow(title: 'Start'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
        if (points.length > 1) markers.add(Marker(markerId: const MarkerId('end'), position: points.last, infoWindow: const InfoWindow(title: 'End'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed))); }
      setState(() { _markers = markers; if (points.length > 1) _polylines = {Polyline(polylineId: const PolylineId('route'), points: points, color: const Color(0xFF6C63FF), width: 4)}; if (points.isNotEmpty) _center = points.first; _isLoading = false; });
      if (_mapController != null && points.isNotEmpty) _mapController!.animateCamera(CameraUpdate.newLatLng(_center));
    } else { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(title: Text(widget.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF0A0A0F), elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : GoogleMap(initialCameraPosition: CameraPosition(target: _center, zoom: 14), polylines: _polylines, markers: _markers, onMapCreated: (controller) => _mapController = controller, myLocationEnabled: false, zoomControlsEnabled: true),
    );
  }
}