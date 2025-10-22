import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../database/models/vehicle.dart';
import 'maintenance_log_page.dart';
import 'ai_suggestions_page.dart';

class VehicleDetailsPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TextEditingController _mileageController;
  late TextEditingController _maintenanceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mileageController = TextEditingController(text: widget.vehicle.mileage ?? '');
    _maintenanceController = TextEditingController(text: widget.vehicle.lastMaintenanceService ?? '');
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  Future<void> _updateVehicle() async {
    if (_mileageController.text.isEmpty && _maintenanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in at least one field')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _dbHelper.init();
      
      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        vin: widget.vehicle.vin,
        make: widget.vehicle.make,
        model: widget.vehicle.model,
        year: widget.vehicle.year,
        car: widget.vehicle.car,
        mileage: _mileageController.text.isNotEmpty ? _mileageController.text : null,
        lastMaintenanceService: _maintenanceController.text.isNotEmpty ? _maintenanceController.text : null,
        createdAt: widget.vehicle.createdAt,
      );

      await _dbHelper.updateVehicle(updatedVehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully!')),
        );
        Navigator.pop(context, 'updated');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating vehicle: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VIN: ${widget.vehicle.vin}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (widget.vehicle.car.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${widget.vehicle.car}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Form Fields
            const Text(
              'Vehicle Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Mileage',
                hintText: 'Enter current mileage',
                prefixIcon: Icon(Icons.speed),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _maintenanceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Last Maintenance Service',
                hintText: 'Enter last maintenance service',
                prefixIcon: Icon(Icons.build),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaintenanceLogPage(vehicle: widget.vehicle),
                            ),
                          );
                        },
                        icon: const Icon(Icons.build),
                        label: const Text('Maintenance Log'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.purple[400],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AISuggestionsPage(vehicle: widget.vehicle),
                            ),
                          );
                        },
                        icon: const Icon(Icons.psychology),
                        label: const Text('AI Suggestions'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[400],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isLoading ? null : _updateVehicle,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Vehicle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
