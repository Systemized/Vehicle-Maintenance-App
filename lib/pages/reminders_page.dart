import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/models/reminder.dart';
import '../database/models/vehicle.dart';
import 'add_reminder_page.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Reminder> _reminders = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _dbHelper.init();
      final reminders = await _dbHelper.getAllReminders();
      final vehicles = await _dbHelper.getAllVehicles();
      
      setState(() {
        _reminders = reminders;
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAddReminder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (context) => const AddReminderPage(),
      ),
    );

    if (!context.mounted) return;

    if (result == 'added') {
      _loadData();
    }
  }

  Future<void> _markAsCompleted(Reminder reminder) async {
    try {
      await _dbHelper.markReminderCompleted(reminder.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder marked as completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reminder: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
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
        await _dbHelper.deleteReminder(reminder.id!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting reminder: $e')),
          );
        }
      }
    }
  }

  Vehicle? _getVehicleById(int vehicleId) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reminders.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No reminders set',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to add your first reminder',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddReminder,
          backgroundColor: Colors.blue[400],
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: Colors.red[600]),
                          const SizedBox(height: 8),
                          Text(
                            '${_reminders.where((r) => r.isOverdue).length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                          ),
                          Text(
                            'Overdue',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.schedule, color: Colors.orange[600]),
                          const SizedBox(height: 8),
                          Text(
                            '${_reminders.where((r) => r.isDueSoon).length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[600],
                            ),
                          ),
                          Text(
                            'Due Soon',
                            style: TextStyle(color: Colors.orange[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Reminders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                final vehicle = _getVehicleById(reminder.vehicleId);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: reminder.isOverdue
                          ? Colors.red
                          : reminder.isDueSoon
                              ? Colors.orange
                              : Colors.blue,
                      child: Icon(
                        reminder.isCompleted ? Icons.check : Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      reminder.serviceType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reminder.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.directions_car, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              vehicle != null
                                  ? '${vehicle.year} ${vehicle.make} ${vehicle.model}'
                                  : 'Unknown Vehicle',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(reminder.dueDate),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!reminder.isCompleted)
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _markAsCompleted(reminder),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(reminder),
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
        onPressed: _navigateToAddReminder,
        backgroundColor: Colors.blue[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}