import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';

class TripMapScreen extends StatefulWidget {
  final int tripId;
  final String title;
  const TripMapScreen({super.key, required this.tripId, required this.title});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = true;
  LatLng _center = const LatLng(13.0827, 80.2707);

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final data = await ApiService.getTripRoute(widget.tripId);

    if (data != null) {
      List<LatLng> points = [];

      double startLat = data['start_lat'] ?? 0;
      double startLng = data['start_lng'] ?? 0;
      double endLat = data['end_lat'] ?? 0;
      double endLng = data['end_lng'] ?? 0;

      if (startLat != 0 && startLng != 0) {
        points.add(LatLng(startLat, startLng));
      }

      List locations = data['locations'] ?? [];
      for (var loc in locations) {
        points.add(LatLng(loc['latitude'], loc['longitude']));
      }

      if (endLat != 0 && endLng != 0) {
        points.add(LatLng(endLat, endLng));
      }

      Set<Marker> markers = {};
      if (points.isNotEmpty) {
        markers.add(Marker(
          markerId: const MarkerId('start'),
          position: points.first,
          infoWindow: const InfoWindow(title: 'Start'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));

        if (points.length > 1) {
          markers.add(Marker(
            markerId: const MarkerId('end'),
            position: points.last,
            infoWindow: const InfoWindow(title: 'End'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
        }
      }

      setState(() {
        _markers = markers;
        if (points.length > 1) {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: const Color(0xFF00D2FF),
              width: 4,
            ),
          };
        }
        if (points.isNotEmpty) {
          _center = points.first;
        }
        _isLoading = false;
      });

      if (_mapController != null && points.isNotEmpty) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(_center));
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF16213E),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14,
              ),
              polylines: _polylines,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: false,
              zoomControlsEnabled: true,
            ),
    );
  }
}