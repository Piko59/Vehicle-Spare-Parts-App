import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/data_service.dart';

class AddPartPage extends StatefulWidget {
  @override
  _AddPartPageState createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  List<File> imageFiles = [];
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  bool _isNew = true;
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _selectedVehicleType;
  String? _selectedCategory;
  String? _selectedBrand;

  bool _isLoading = false;

  final Map<String, List<String>> vehicleCategories = DataService.vehicleCategories;
  final Map<String, List<String>> vehicleBrands = DataService.vehicleBrands;

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      if (imageFiles.length + pickedFiles.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can select up to 6 images only.')),
        );
        return;
      }
      setState(() {
        imageFiles.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      });
    }
  }

  Future<void> _savePart() async {
    if (imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = [];

      for (File file in imageFiles) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('parts')
            .child('$fileName.jpg');

        firebase_storage.UploadTask uploadTask = ref.putFile(file);
        firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

        final String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final Timestamp timestamp = Timestamp.now();

      DocumentReference partDocRef = await FirebaseFirestore.instance.collection('parts').add({
        'image_urls': imageUrls,
        'vehicle_type': _selectedVehicleType,
        'category': _selectedCategory,
        'brand': _selectedBrand,
        'title': _titleController.text,
        'year': int.parse(_yearController.text),
        'isNew': _isNew,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'user_id': user.uid,
        'timestamp': timestamp,
      });

      DatabaseReference realtimeUserRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      await realtimeUserRef.child('products').update({
        partDocRef.id: true,
      });

      _titleController.clear();
      _yearController.clear();
      setState(() {
        _isNew = true;
        imageFiles = [];
        _selectedVehicleType = null;
        _selectedCategory = null;
        _selectedBrand = null;
      });
      _priceController.clear();
      _descriptionController.clear();

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add part: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Part added successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add Part',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: imageFiles.isEmpty
                      ? Center(child: Text('Choose Images'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: imageFiles.length < 6 ? imageFiles.length + 1 : 6,
                          itemBuilder: (context, index) {
                            if (index == imageFiles.length) {
                              return IconButton(
                                icon: Icon(Icons.add),
                                onPressed: _pickImages,
                              );
                            }
                            File file = imageFiles[index];
                            return Stack(
                              children: [
                                Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        imageFiles.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
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
              SizedBox(height: 10),
              _buildTextInput('Title', _titleController),
              _buildTextInput('Description', _descriptionController),
              _buildTextInput('Price', _priceController, inputType: TextInputType.number),
              _buildTextInput('Year', _yearController, inputType: TextInputType.number),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'New Part?',
                    style: TextStyle(fontSize: 16),
                  ),
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
              SizedBox(height: 10),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF76CE),
                            Color(0xFFA3D8FF),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ElevatedButton(
                        onPressed: _savePart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: Text(
                          'Save Part',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
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
