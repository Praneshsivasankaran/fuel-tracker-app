import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _modelController = TextEditingController();
  final _engineSizeController = TextEditingController();
  String _selectedFuelType = 'Petrol';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'CNG'];

  Future<void> _addVehicle() async {
    if (_modelController.text.trim().isEmpty || _engineSizeController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'All fields are required');
      return;
    }

    double? engineSize = double.tryParse(_engineSizeController.text.trim());
    if (engineSize == null || engineSize <= 0) {
      setState(() => _errorMessage = 'Enter a valid engine size');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.addVehicle(
      _modelController.text.trim(),
      engineSize,
      _selectedFuelType,
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = 'Failed to add vehicle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Add Vehicle', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF16213E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 60,
                  color: Color(0xFF00D2FF),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Vehicle Model', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
            const SizedBox(height: 8),
            TextField(
              controller: _modelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Honda City, Swift, i20',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF00D2FF)),
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Engine Size (Litres)', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
            const SizedBox(height: 8),
            TextField(
              controller: _engineSizeController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 1.2, 1.5, 2.0',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.speed, color: Color(0xFF00D2FF)),
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Fuel Type', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFuelType,
                  dropdownColor: const Color(0xFF16213E),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00D2FF)),
                  items: _fuelTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedFuelType = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D2FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add Vehicle',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}