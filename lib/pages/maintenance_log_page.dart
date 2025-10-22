import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/models/vehicle.dart';
import '../database/models/maintenance.dart';
import 'add_maintenance_page.dart';

class MaintenanceLogPage extends StatefulWidget {
  final Vehicle vehicle;

  const MaintenanceLogPage({super.key, required this.vehicle});

  @override
  State<MaintenanceLogPage> createState() => _MaintenanceLogPageState();
}

class _MaintenanceLogPageState extends State<MaintenanceLogPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Maintenance> _maintenanceRecords = [];
  double _totalCost = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRecords();
  }

  Future<void> _loadMaintenanceRecords() async {
    try {
      await _dbHelper.init();
      final records = await _dbHelper.getMaintenanceByVehicleId(widget.vehicle.id!);
      final totalCost = await _dbHelper.getTotalMaintenanceCost(widget.vehicle.id!);
      
      setState(() {
        _maintenanceRecords = records;
        _totalCost = totalCost;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance records: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAddMaintenance() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (context) => AddMaintenancePage(vehicle: widget.vehicle),
      ),
    );

    if (!context.mounted) return;

    if (result == 'added') {
      _loadMaintenanceRecords();
    }
  }

  Future<void> _deleteMaintenance(Maintenance maintenance) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Maintenance Record'),
          content: const Text('Are you sure you want to delete this maintenance record?'),
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
        await _dbHelper.deleteMaintenance(maintenance.id!);
        _loadMaintenanceRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance record deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting record: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model} - Maintenance'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Maintenance Cost',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${_totalCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_maintenanceRecords.length} service records',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Maintenance Records List
                Expanded(
                  child: _maintenanceRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.build_circle_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No maintenance records',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first service record',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _maintenanceRecords.length,
                          itemBuilder: (context, index) {
                            final maintenance = _maintenanceRecords[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getServiceTypeColor(maintenance.serviceType),
                                  child: Icon(
                                    _getServiceTypeIcon(maintenance.serviceType),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  maintenance.serviceType,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(maintenance.description),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(maintenance.serviceDate),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.speed, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${maintenance.mileage} miles',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${maintenance.cost.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteMaintenance(maintenance),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMaintenance,
        backgroundColor: Colors.blue[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getServiceTypeColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'oil change':
        return Colors.orange;
      case 'tire rotation':
        return Colors.blue;
      case 'inspection':
        return Colors.green;
      case 'brake service':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceTypeIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'oil change':
        return Icons.oil_barrel;
      case 'tire rotation':
        return Icons.rotate_right;
      case 'inspection':
        return Icons.search;
      case 'brake service':
        return Icons.stop_circle;
      default:
        return Icons.build;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
