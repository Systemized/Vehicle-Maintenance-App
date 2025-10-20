import 'package:flutter/material.dart';

class NewVehiclePage extends StatelessWidget {
  const NewVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Add New Vehicle", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    );
  }
}