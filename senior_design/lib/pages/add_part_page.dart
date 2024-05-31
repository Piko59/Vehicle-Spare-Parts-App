import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'home_page.dart';

class AddPartPage extends StatefulWidget {
  @override
  _AddPartPageState createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  bool _isNew = true;
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _selectedVehicleType;
  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedPartCategory;

  final Map<String, List<String>> vehicleCategories = {
    'Car': [
      'Ignition & Fuel',
      'Exhaust',
      'Electric',
      'Filter',
      'Brake & Clutch',
      'Heating & Ventilation & Air Conditioning',
      'Mechanical',
      'Engine',
      'Transmission & Gear',
      'Steering & Suspension',
    ],
    'Motorcycle': [
      'Clutch',
      'Exhaust',
      'Electric',
      'Brake',
      'Fairing',
      'Ventilation',
      'Engine',
      'Suspension',
      'Transmission',
      'Lubrication',
      'Fuel System',
      'Steering',
    ],
    'Bicycle': [
      'Handlebar',
      'Brake',
      'Rotor',
      'Bearing',
      'Rim',
      'Frame',
      'Drivetrain Components',
      'Electric Components',
      'Cockpit',
      'Brake Pad',
    ],
  };

  final Map<String, List<String>> vehicleBrands = {
    'Car': [
      'Toyota',
      'Honda',
      'Ford',
      'BMW',
      'Mercedes',
    ],
    'Motorcycle': [
      'Yamaha',
      'Honda',
      'Suzuki',
      'Kawasaki',
      'Ducati',
    ],
    'Bicycle': [
      'Giant',
      'Trek',
      'Specialized',
      'Cannondale',
      'Bianchi',
    ],
  };

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePart() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('parts')
          .child('$fileName.jpg');

      firebase_storage.UploadTask uploadTask = ref.putFile(_image!);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

      final String imageUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('parts').add({
        'image_url': imageUrl,
        'vehicle_type': _selectedVehicleType,
        'category': _selectedCategory,
        'partCategory': _selectedPartCategory,
        'brand': _selectedBrand,
        'title': _titleController.text,
        'year': int.parse(_yearController.text),
        'isNew': _isNew,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
      });

      _titleController.clear();
      _yearController.clear();
      setState(() {
        _isNew = true;
        _image = null;
        _selectedVehicleType = null;
        _selectedCategory = null;
        _selectedBrand = null;
      });
      _priceController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Part added successfully!'),
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add part: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Part',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF00A9B7),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(_image!),
                ),
              ElevatedButton(
                onPressed: _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00A9B7),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Select Image', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Select Vehicle Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVehicleType = newValue;
                    _selectedCategory = null;
                    _selectedBrand = null;
                  });
                },
                items: vehicleCategories.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (_selectedVehicleType != null)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      _selectedPartCategory = newValue;
                    });
                  },
                  items: vehicleCategories[_selectedVehicleType]!
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              if (_selectedVehicleType != null)
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: InputDecoration(
                    labelText: 'Select Brand',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBrand = newValue;
                    });
                  },
                  items: vehicleBrands[_selectedVehicleType]!
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              _buildTextInput('Title', _titleController),
              _buildTextInput('Year', _yearController),
              Row(
                children: [
                  Text('Is New?'),
                  Checkbox(
                    value: _isNew,
                    onChanged: (bool? value) {
                      setState(() {
                        _isNew = value ?? true;
                      });
                    },
                  ),
                ],
              ),
              _buildTextInput('Price', _priceController),
              _buildTextInput('Description', _descriptionController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00A9B7),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Save Part', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
