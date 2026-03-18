import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  List<dynamic> _brands = [];
  List<dynamic> _models = [];
  String? _selectedBrand;
  Map<String, dynamic>? _selectedModel;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final brands = await ApiService.getVehicleBrands();
    setState(() {
      _brands = brands;
      _isLoading = false;
    });
  }

  Future<void> _loadModels(String brand) async {
    setState(() => _isLoading = true);
    final models = await ApiService.getVehicleDatabase(brand: brand);
    setState(() {
      _models = models;
      _selectedModel = null;
      _isLoading = false;
    });
  }

  Future<void> _addVehicle() async {
    if (_selectedModel == null) {
      setState(() => _errorMessage = 'Please select a vehicle');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    String modelName = '${_selectedModel!['brand']} ${_selectedModel!['model']} ${_selectedModel!['variant'] ?? ''}'.trim();
    double engineSize = (_selectedModel!['engine_size'] ?? 1.0).toDouble();
    String fuelType = _selectedModel!['fuel_type'] ?? 'Petrol';

    final result = await ApiService.addVehicle(modelName, engineSize, fuelType);

    setState(() => _isSaving = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully!'), backgroundColor: Colors.green),
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
                child: const Icon(Icons.directions_car, size: 60, color: Color(0xFF00D2FF)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('Select from Indian Car Database', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white54)),
            ),
            const SizedBox(height: 24),

            // Brand Dropdown
            Text('Brand', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
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
                  value: _selectedBrand,
                  hint: Text('Select Brand', style: GoogleFonts.poppins(color: Colors.white38)),
                  dropdownColor: const Color(0xFF16213E),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00D2FF)),
                  isExpanded: true,
                  items: _brands.map<DropdownMenuItem<String>>((brand) {
                    return DropdownMenuItem(value: brand.toString(), child: Text(brand.toString()));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _selectedModel = null;
                    });
                    if (value != null) _loadModels(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Model Selection
            if (_selectedBrand != null) ...[
              Text('Model', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
              else
                ..._models.map((model) => _buildModelCard(model)),
            ],

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
              ),

            const SizedBox(height: 24),

            // Add Button
            if (_selectedModel != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _addVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D2FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Add Vehicle',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(dynamic model) {
    bool isSelected = _selectedModel != null && _selectedModel!['id'] == model['id'];
    double mileage = (model['mileage_kmpl'] ?? 0).toDouble();

    return GestureDetector(
      onTap: () {
        setState(() => _selectedModel = model);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D2FF).withValues(alpha: 0.15) : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF00D2FF), width: 2) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['model']} ${model['variant'] ?? ''}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Text(
                    '${model['engine_size']}L • ${model['fuel_type']} • ${model['body_type']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${mileage.toStringAsFixed(1)} km/l',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.greenAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}