import 'dart:convert';
import 'package:http/http.dart' as http;

class VinLookupService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/';
  
  static Future<Map<String, String>?> lookupVin(String vin) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$vin?format=json'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;
        
        if (results.isNotEmpty) {
          String make = '';
          String model = '';
          String year = '';
          String car = '';
          
          for (var result in results) {
            final variable = result['Variable'] as String?;
            final value = result['Value'] as String?;
            
            if (value != null && value.isNotEmpty) {
              switch (variable) {
                case 'Make':
                  make = value;
                  break;
                case 'Model':
                  model = value;
                  break;
                case 'Model Year':
                  year = value;
                  break;
                case 'Vehicle Type':
                  car = value;
                  break;
              }
            }
          }
          
          if (make.isNotEmpty && model.isNotEmpty && year.isNotEmpty) {
            return {
              'vin': vin,
              'make': make,
              'model': model,
              'year': year,
              'car': car.isNotEmpty ? car : 'Unknown',
            };
          }
        }
      }
    } catch (e) {
      // Error looking up VIN - return null to indicate failure
    }
    
    return null;
  }
}
