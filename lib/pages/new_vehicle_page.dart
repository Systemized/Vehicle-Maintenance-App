import 'package:flutter/material.dart';

class NewVehiclePage extends StatelessWidget {
  const NewVehiclePage({super.key});

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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Vin Number',
            ),
          ),
          SizedBox(height: 20),

          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 75, vertical: 25),
              backgroundColor: Colors.blue[400],
            ),
            onPressed: () {
            },
            child: Text('Add Vehicle', style: TextStyle(color: Colors.white)),
          ),

        ],
      ),
    );
  }
}


