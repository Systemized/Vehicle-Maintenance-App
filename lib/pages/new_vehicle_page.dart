import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewVehiclePage extends StatefulWidget {
  const NewVehiclePage({super.key});

  @override
  State<NewVehiclePage> createState() => _NewVehiclePageState();
}

class _NewVehiclePageState extends State<NewVehiclePage> {
  final TextEditingController _vinController = TextEditingController();
  bool _isValidVin = false;

  @override
  void initState() {
    super.initState();
    _vinController.addListener(_validateVin);
  }

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  void _validateVin() {
    setState(() {
      _isValidVin = _vinController.text.length == 16;
    });
  }

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
            controller: _vinController,
            maxLength: 16,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'VIN Number',
              hintText: 'Enter VIN number',
              counterText: '${_vinController.text.length}',
              errorText: _vinController.text.isNotEmpty && _vinController.text.length != 16
                  ? 'Enter 16 Chracters'
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _isValidVin = value.length == 17;
              });
            },
          ),
          SizedBox(height: 20),

          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 75, vertical: 25),
              backgroundColor: _isValidVin ? Colors.blue[400] : Colors.grey[400],
            ),
            onPressed: _isValidVin ? () {
              // TODO: Add vehicle logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Vehicle added successfully!')),
              );
            } : null,
            child: Text('Add Vehicle', style: TextStyle(color: Colors.white)),
          ),

        ],
      ),
    );
  }
}


