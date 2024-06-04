import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditPartPage extends StatefulWidget {
  final String productId;

  EditPartPage({required this.productId});

  @override
  _EditPartPageState createState() => _EditPartPageState();
}

class _EditPartPageState extends State<EditPartPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  Map<String, dynamic>? _productData;

  String? _selectedVehicleType;
  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedPartCategory;
  bool _isNew = true;
  File? _image;
  final picker = ImagePicker();
  String? _imageUrl;

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

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      final DocumentSnapshot productSnapshot = await _firestore.collection('parts').doc(widget.productId).get();
      if (productSnapshot.exists) {
        setState(() {
          _productData = productSnapshot.data() as Map<String, dynamic>;
          _titleController.text = _productData!['title'] ?? '';
          _priceController.text = _productData!['price'].toString();
          _descriptionController.text = _productData!['description'] ?? '';
          _yearController.text = _productData!['year'].toString();
          _selectedVehicleType = _productData!['vehicle_type'];
          _selectedCategory = _productData!['category'];
          _selectedBrand = _productData!['brand'];
          _selectedPartCategory = _productData!['partCategory'];
          _isNew = _productData!['isNew'] ?? true;
          _imageUrl = _productData!['image_url'];
        });
      }
    } catch (e) {
      print('Error loading product data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteOldImage() async {
    if (_imageUrl != null) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(_imageUrl!);
        await ref.delete();
      } catch (e) {
        print('Error deleting old image: $e');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _deleteOldImage();

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('parts/$fileName.jpg');
      await storageRef.putFile(_image!);
      _imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload image: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_image != null) {
      await _uploadImage();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('parts').doc(widget.productId).update({
        'title': _titleController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'year': int.parse(_yearController.text),
        'vehicle_type': _selectedVehicleType,
        'category': _selectedCategory,
        'partCategory': _selectedPartCategory,
        'brand': _selectedBrand,
        'isNew': _isNew,
        'image_url': _imageUrl,
      });

      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save changes: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFFF76CE),
                  Color(0xFFA3D8FF),
                ],
              ),
            ),
          ),
          title: Text('Edit Part',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: _productData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image == null
                          ? (_imageUrl != null
                              ? Image.network(_imageUrl!, fit: BoxFit.cover)
                              : Center(child: Text('Choose an Image')))
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextInput('Title', _titleController),
                  _buildTextInput('Description', _descriptionController),
                  _buildTextInput('Price', _priceController, inputType: TextInputType.number),
                  _buildTextInput('Year', _yearController, inputType: TextInputType.number),
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
                  SizedBox(height: 20),
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
                    items: (_selectedVehicleType != null
                            ? vehicleCategories[_selectedVehicleType]!
                            : <String>[])
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
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
                    items: (_selectedVehicleType != null
                            ? vehicleBrands[_selectedVehicleType]!
                            : <String>[])
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Is New? ',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 10),
                      Switch(
                        value: _isNew,
                        onChanged: (bool? value) {
                          setState(() {
                            _isNew = value ?? true;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF76CE), Color(0xFFA3D8FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              alignment: Alignment.center,
                              constraints: BoxConstraints(minHeight: 50),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller, {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: inputType,
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
