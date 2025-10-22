import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../database/models/vehicle.dart';
import '../services/vin_lookup_service.dart';

class NewVehiclePage extends StatefulWidget {
  const NewVehiclePage({super.key});

  @override
  State<NewVehiclePage> createState() => _NewVehiclePageState();
}

class _NewVehiclePageState extends State<NewVehiclePage> {
  final TextEditingController _vinController = TextEditingController();
  bool _isValidVin = false;
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _vinController.addListener(_validateVin);
  }

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  void _validateVin() {
    setState(() {
      _isValidVin = _vinController.text.length == 17;
    });
  }

  Future<void> _addVehicle() async {
    if (!_isValidVin) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize database
      await _dbHelper.init();
      
      // Look up VIN information
      final vehicleData = await VinLookupService.lookupVin(_vinController.text);
      
      if (vehicleData != null) {
        // Create vehicle object
        final vehicle = Vehicle(
          vin: vehicleData['vin']!,
          make: vehicleData['make']!,
          model: vehicleData['model']!,
          year: vehicleData['year']!,
          car: vehicleData['car']!,
          createdAt: DateTime.now().toIso8601String(),
        );
        
        // Save to database
        await _dbHelper.insertVehicle(vehicle);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully!')),
          );
          _vinController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find vehicle information for this VIN.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Add New Vehicle', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            controller: _vinController,
            maxLength: 17,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'VIN Number',
              hintText: 'Enter VIN number',
              counterText: '${_vinController.text.length}/17',
              errorText: _vinController.text.isNotEmpty && _vinController.text.length != 17
                  ? 'Enter 17 Characters'
                  : null,
            ),
          ),
          SizedBox(height: 20),

          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 75, vertical: 25),
              backgroundColor: _isValidVin && !_isLoading ? Colors.blue[400] : Colors.grey[400],
            ),
            onPressed: _isValidVin && !_isLoading ? _addVehicle : null,
            child: _isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Add Vehicle', style: TextStyle(color: Colors.white)),
          ),

        ],
      ),
    );
  }
}


