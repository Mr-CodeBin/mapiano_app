import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapiano_app/services/temp_service.dart';
import 'package:mapiano_app/widgets/cust_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final _locationController = TextEditingController();

  void _submitLocation() {
    if (_formKey.currentState!.validate()) {
      String location = _locationController.text.trim();
      Navigator.of(context).pushNamed('/mapScreen', arguments: location);
    }
  }

  bool isCorrectValue(String value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    if (value.length < 3) {}

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Location',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _locationController,
                labelText: 'Location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  if (value.length < 3) {
                    return 'Please enter a valid location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLocation,
                child: Text(
                  'Show on Map',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
