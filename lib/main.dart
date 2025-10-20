import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/new_vehicle_page.dart';
import 'pages/reminders_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: VehicleMaintenanceApp());
  }
}

class VehicleMaintenanceApp extends StatefulWidget {
  const VehicleMaintenanceApp({super.key});

  @override
  State<VehicleMaintenanceApp> createState() => _VehicleMaintenanceAppState();
}

class _VehicleMaintenanceAppState extends State<VehicleMaintenanceApp> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    NewVehiclePage(),
    RemindersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Maintenance App')),
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Reminders'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}