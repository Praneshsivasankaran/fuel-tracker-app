import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static String? _token;
  static String? get token => _token;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      return {'success': true, 'token': _token};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['detail'] ?? 'Login failed'};
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['detail'] ?? 'Registration failed'};
    }
  }

  static Future<Map<String, dynamic>?> addVehicle(String model, double engineSize, String fuelType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'vehicle_model': model,
        'engine_size': engineSize,
        'fuel_type': fuelType,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<List<dynamic>> getVehicles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<List<dynamic>> getTrips() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<Map<String, dynamic>?> startTrip(int vehicleId, double lat, double lng) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trip/start'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'vehicle_id': vehicleId,
        'start_lat': lat,
        'start_lng': lng,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<bool> sendLocation(int tripId, double lat, double lng, double speed) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trip/location'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'trip_id': tripId,
        'latitude': lat,
        'longitude': lng,
        'speed': speed,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> endTrip(int tripId, double endLat, double endLng,
      double distance, double avgSpeed, double maxSpeed, double avgAccel, double duration) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trip/end'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'trip_id': tripId,
        'end_lat': endLat,
        'end_lng': endLng,
        'total_distance': distance,
        'avg_speed': avgSpeed,
        'max_speed': maxSpeed,
        'avg_acceleration': avgAccel,
        'trip_duration': duration,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<List<dynamic>> getVehicleBrands() async {
    final response = await http.get(
      Uri.parse('$baseUrl/vehicle-database/brands'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<List<dynamic>> getVehicleDatabase({String? brand}) async {
    String url = '$baseUrl/vehicle-database';
    if (brand != null) url += '?brand=$brand';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<Map<String, dynamic>?> getTripRoute(int tripId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trip/$tripId/route'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<bool> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token != null;
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}