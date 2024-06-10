import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/data_service.dart';

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
  bool _isNew = true;
  List<File> _images = [];
  final picker = ImagePicker();
  List<String> _imageUrls = [];

  final Map<String, List<String>> vehicleCategories = DataService.vehicleCategories;
  final Map<String, List<String>> vehicleBrands = DataService.vehicleBrands;

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
          _isNew = _productData!['isNew'] ?? true;
          _imageUrls = List<String>.from(_productData!['image_urls'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading product data: $e');
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (_images.length + _imageUrls.length + pickedFiles.length > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can select up to 6 images only.')),
      );
      return;
    }
    setState(() {
      _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
    });
    }

  Future<void> _deleteOldImages() async {
    for (String imageUrl in _imageUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        print('Error deleting old image: $e');
      }
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      setState(() {
        _imageUrls.remove(imageUrl);
      });
    } catch (e) {
      print('Error deleting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete image: $e'),
      ));
    }
  }

  Future<void> _uploadImages() async {
    if (_images.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _deleteOldImages();

      List<String> newImageUrls = [];
      for (File image in _images) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref().child('parts/$fileName.jpg');
        await storageRef.putFile(image);
        String imageUrl = await storageRef.getDownloadURL();
        newImageUrls.add(imageUrl);
      }
      _imageUrls = newImageUrls;
    } catch (e) {
      print('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload images: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_images.isNotEmpty) {
      await _uploadImages();
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
        'brand': _selectedBrand,
        'isNew': _isNew,
        'image_urls': _imageUrls,
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Part',
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
      body: _productData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
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
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _imageUrls.length + _images.length < 6
                            ? _imageUrls.length + _images.length + 1
                            : 6,
                        itemBuilder: (context, index) {
                          if (index < _imageUrls.length) {
                            return Stack(
                              children: [
                                Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _deleteImage(_imageUrls[index]);
                                    },
                                    child: Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (index < _imageUrls.length + _images.length) {
                            int imageIndex = index - _imageUrls.length;
                            return Stack(
                              children: [
                                Image.file(
                                  _images[imageIndex],
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
                                        _images.removeAt(imageIndex);
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
                          } else {
                            return IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _pickImages,
                            );
                          }
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
                        'Is New?',
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
