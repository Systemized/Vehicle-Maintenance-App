import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/models/vehicle.dart';
import '../services/ai_suggestion_service.dart';

class AISuggestionsPage extends StatefulWidget {
  final Vehicle vehicle;

  const AISuggestionsPage({super.key, required this.vehicle});

  @override
  State<AISuggestionsPage> createState() => _AISuggestionsPageState();
}

class _AISuggestionsPageState extends State<AISuggestionsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _suggestions = [];
  // List<Maintenance> _maintenanceHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      await _dbHelper.init();
      final maintenanceHistory = await _dbHelper.getMaintenanceByVehicleId(widget.vehicle.id!);
      final suggestions = AISuggestionService.getServiceSuggestions(widget.vehicle, maintenanceHistory);
      
      setState(() {
        // _maintenanceHistory = maintenanceHistory;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading suggestions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Suggestions - ${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}'),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Card
                Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.purple[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.purple[600], size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'AI-Powered Maintenance Suggestions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Based on your vehicle\'s age, mileage, and maintenance history',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Suggestions List
                Expanded(
                  child: _suggestions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 80,
                                color: Colors.green[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All caught up!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your vehicle maintenance is up to date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            final serviceType = suggestion.split(' - ')[0];
                            final priority = AISuggestionService.getMaintenancePriority(serviceType);
                            final estimatedCost = AISuggestionService.getEstimatedCost(serviceType);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getPriorityColor(priority),
                                  child: Icon(
                                    _getServiceIcon(serviceType),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  serviceType,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(suggestion.split(' - ')[1]),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(priority).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            priority,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getPriorityColor(priority),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 2),
                                        Text(
                                          estimatedCost,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.purple[400],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High Priority':
        return Colors.red;
      case 'Medium Priority':
        return Colors.orange;
      case 'Low Priority':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    if (serviceType.toLowerCase().contains('oil')) {
      return Icons.oil_barrel;
    } else if (serviceType.toLowerCase().contains('tire')) {
      return Icons.rotate_right;
    } else if (serviceType.toLowerCase().contains('brake')) {
      return Icons.stop_circle;
    } else if (serviceType.toLowerCase().contains('battery')) {
      return Icons.battery_charging_full;
    } else if (serviceType.toLowerCase().contains('inspection')) {
      return Icons.search;
    } else {
      return Icons.build;
    }
  }
}
