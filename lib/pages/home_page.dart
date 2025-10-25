import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/models/vehicle.dart';
import 'vehicle_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      await _dbHelper.init();
      final vehicles = await _dbHelper.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    }
  }

  Future<void> _navigateToVehicleDetails(Vehicle vehicle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (context) => VehicleDetailsPage(vehicle: vehicle),
      ),
    );

    if (!context.mounted) return;

    // If the vehicle was updated, reload the list
    if (result == 'updated') {
      _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text('Are you sure you want to delete ${vehicle.year} ${vehicle.make} ${vehicle.model}? This will also delete all associated maintenance records and reminders.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _dbHelper.deleteVehicle(vehicle.id!);
        _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting vehicle: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.blue[50],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Container(
        color: Colors.blue[50],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No vehicles added yet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Add a vehicle using the VIN number',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Vehicles',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => _navigateToVehicleDetails(vehicle),
                      borderRadius: BorderRadius.circular(8),
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
                                    '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deleteVehicle(vehicle);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete Vehicle'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: const Icon(Icons.more_vert, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'VIN: ${vehicle.vin}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (vehicle.car.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${vehicle.car}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (vehicle.mileage != null || vehicle.lastMaintenanceService != null) ...[
                              Row(
                                children: [
                                  if (vehicle.mileage != null) ...[
                                    Icon(Icons.speed, size: 16, color: Colors.blue[400]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Mileage: ${vehicle.mileage}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  if (vehicle.lastMaintenanceService != null) ...[
                                    Icon(Icons.build, size: 16, color: Colors.orange[400]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Last Service: ${vehicle.lastMaintenanceService}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[400],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ] else ...[
                              const Text(
                                'Tap to add mileage and maintenance details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Added: ${_formatDate(vehicle.createdAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}