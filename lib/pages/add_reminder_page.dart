import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/models/vehicle.dart';
import '../database/models/reminder.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mileageIntervalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  Vehicle? _selectedVehicle;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  List<Vehicle> _vehicles = [];

  final List<String> _commonServiceTypes = [
    'Oil Change',
    'Tire Rotation',
    'Inspection',
    'Brake Service',
    'Transmission Service',
    'Air Filter Replacement',
    'Battery Check',
    'Coolant Flush',
    'Spark Plug Replacement',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _mileageIntervalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      await _dbHelper.init();
      final vehicles = await _dbHelper.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        if (vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reminder = Reminder(
        vehicleId: _selectedVehicle!.id!,
        serviceType: _serviceTypeController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        mileageInterval: int.parse(_mileageIntervalController.text),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _dbHelper.insertReminder(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder added successfully!')),
        );
        Navigator.pop(context, 'added');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding reminder: $e')),
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
        title: const Text('Add Reminder'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Selection
              DropdownButtonFormField<Vehicle>(
                initialValue: _selectedVehicle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Vehicle',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: _vehicles.map((Vehicle vehicle) {
                  return DropdownMenuItem<Vehicle>(
                    value: vehicle,
                    child: Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
                  );
                }).toList(),
                onChanged: (Vehicle? newValue) {
                  setState(() {
                    _selectedVehicle = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a vehicle';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Service Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _serviceTypeController.text.isEmpty ? null : _serviceTypeController.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Service Type',
                  prefixIcon: Icon(Icons.build),
                ),
                items: _commonServiceTypes.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _serviceTypeController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service type';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                  hintText: 'Describe the service needed',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date and Mileage Interval Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Due Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_formatDate(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _mileageIntervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mileage Interval',
                        hintText: 'e.g., 5000',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mileage interval';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional notes about the reminder',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[400],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _saveReminder,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Reminder',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
