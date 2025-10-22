import '../database/models/vehicle.dart';
import '../database/models/maintenance.dart';

class AISuggestionService {
  static List<String> getServiceSuggestions(Vehicle vehicle, List<Maintenance> maintenanceHistory) {
    final suggestions = <String>[];
    final currentYear = DateTime.now().year;
    final vehicleAge = currentYear - int.parse(vehicle.year);
    
    // Get last maintenance dates
    final lastOilChange = _getLastServiceDate(maintenanceHistory, 'Oil Change');
    final lastTireRotation = _getLastServiceDate(maintenanceHistory, 'Tire Rotation');
    final lastInspection = _getLastServiceDate(maintenanceHistory, 'Inspection');
    
    // Oil change suggestions
    if (lastOilChange == null || DateTime.now().difference(lastOilChange).inDays > 90) {
      suggestions.add('Oil Change - Recommended every 3 months or 3,000-5,000 miles');
    }
    
    // Tire rotation suggestions
    if (lastTireRotation == null || DateTime.now().difference(lastTireRotation).inDays > 180) {
      suggestions.add('Tire Rotation - Recommended every 6 months or 6,000-8,000 miles');
    }
    
    // Annual inspection
    if (lastInspection == null || DateTime.now().difference(lastInspection).inDays > 365) {
      suggestions.add('Annual Inspection - Comprehensive vehicle check-up');
    }
    
    // Age-based suggestions
    if (vehicleAge >= 5) {
      suggestions.add('Transmission Service - Recommended for vehicles 5+ years old');
    }
    
    if (vehicleAge >= 3) {
      suggestions.add('Coolant Flush - Recommended every 2-3 years');
    }
    
    if (vehicleAge >= 2) {
      suggestions.add('Air Filter Replacement - Check and replace if needed');
    }
    
    // Mileage-based suggestions
    final currentMileage = int.tryParse(vehicle.mileage ?? '0') ?? 0;
    
    if (currentMileage >= 60000) {
      suggestions.add('Timing Belt Replacement - Critical at 60,000+ miles');
    }
    
    if (currentMileage >= 30000) {
      suggestions.add('Brake Service - Check brake pads and fluid');
    }
    
    if (currentMileage >= 15000) {
      suggestions.add('Battery Check - Test battery health and connections');
    }
    
    // Seasonal suggestions
    final month = DateTime.now().month;
    if (month >= 10 || month <= 3) {
      suggestions.add('Winter Preparation - Check tires, battery, and heating system');
    } else if (month >= 4 && month <= 6) {
      suggestions.add('Spring Maintenance - AC system check and tire inspection');
    }
    
    return suggestions.take(5).toList(); // Limit to 5 suggestions
  }
  
  static DateTime? _getLastServiceDate(List<Maintenance> history, String serviceType) {
    try {
      return history
          .where((m) => m.serviceType.toLowerCase().contains(serviceType.toLowerCase()))
          .map((m) => m.serviceDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    } catch (e) {
      return null;
    }
  }
  
  static String getMaintenancePriority(String serviceType) {
    final highPriority = ['Timing Belt', 'Brake Service', 'Transmission Service'];
    final mediumPriority = ['Oil Change', 'Tire Rotation', 'Coolant Flush'];
    
    if (highPriority.any((type) => serviceType.toLowerCase().contains(type.toLowerCase()))) {
      return 'High Priority';
    } else if (mediumPriority.any((type) => serviceType.toLowerCase().contains(type.toLowerCase()))) {
      return 'Medium Priority';
    } else {
      return 'Low Priority';
    }
  }
  
  static String getEstimatedCost(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'oil change':
        return '\$30-\$60';
      case 'tire rotation':
        return '\$20-\$40';
      case 'inspection':
        return '\$50-\$100';
      case 'brake service':
        return '\$150-\$400';
      case 'transmission service':
        return '\$200-\$500';
      case 'timing belt':
        return '\$300-\$800';
      case 'coolant flush':
        return '\$80-\$150';
      case 'air filter':
        return '\$20-\$50';
      case 'battery check':
        return '\$0-\$20';
      default:
        return '\$50-\$200';
    }
  }
}
