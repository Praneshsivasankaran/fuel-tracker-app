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
  void initState() { super.initState(); _loadBrands(); }

  Future<void> _loadBrands() async {
    final brands = await ApiService.getVehicleBrands();
    setState(() { _brands = brands; _isLoading = false; });
  }

  Future<void> _loadModels(String brand) async {
    setState(() => _isLoading = true);
    final models = await ApiService.getVehicleDatabase(brand: brand);
    setState(() { _models = models; _selectedModel = null; _isLoading = false; });
  }

  Future<void> _addVehicle() async {
    if (_selectedModel == null) { setState(() => _errorMessage = 'Please select a vehicle'); return; }
    setState(() { _isSaving = true; _errorMessage = null; });
    String modelName = '${_selectedModel!['brand']} ${_selectedModel!['model']} ${_selectedModel!['variant'] ?? ''}'.trim();
    double engineSize = (_selectedModel!['engine_size'] ?? 1.0).toDouble();
    String fuelType = _selectedModel!['fuel_type'] ?? 'Petrol';
    final result = await ApiService.addVehicle(modelName, engineSize, fuelType);
    setState(() => _isSaving = false);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle added successfully!'), backgroundColor: Color(0xFF00C9A7)));
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = 'Failed to add vehicle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Add Vehicle', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: const Icon(Icons.directions_car_rounded, size: 60, color: Color(0xFF2D7AFF)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text('Select from Indian Vehicle Database', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey))),
            const SizedBox(height: 24),
            Text('Brand', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBrand,
                  hint: Text('Select Brand', style: GoogleFonts.poppins(color: Colors.grey)),
                  dropdownColor: Colors.white,
                  style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontSize: 15),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2D7AFF)),
                  isExpanded: true,
                  items: _brands.map<DropdownMenuItem<String>>((brand) => DropdownMenuItem(value: brand.toString(), child: Text(brand.toString()))).toList(),
                  onChanged: (value) {
                    setState(() { _selectedBrand = value; _selectedModel = null; });
                    if (value != null) _loadModels(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedBrand != null) ...[
              Text('Model', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF2D7AFF)))
              else ..._models.map((model) => _buildModelCard(model)),
            ],
            if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14))),
            const SizedBox(height: 24),
            if (_selectedModel != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _addVehicle,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7AFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Add Vehicle', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
      onTap: () => setState(() => _selectedModel = model),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF2D7AFF) : Colors.grey.shade200, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF2D7AFF).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${model['model']} ${model['variant'] ?? ''}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                  Text('${model['engine_size']}L • ${model['fuel_type']} • ${model['body_type']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF00C9A7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('${mileage.toStringAsFixed(1)} km/l', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00C9A7))),
            ),
          ],
        ),
      ),
    );
  }
}