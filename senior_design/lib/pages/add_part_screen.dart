import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';

class AddPartScreen extends StatefulWidget {
  @override
  _AddPartScreenState createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
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
  String? _selectedPartCategory; // Yeni eklendi

  final Map<String, List<String>> vehicleCategories = {
    'Araba': [
      'Ateşleme & Yakıt',
      'Egzoz',
      'Elektrik',
      'Filtre',
      'Fren & Debriyaj',
      'Isıtma & Havalandırma & Klima',
      'Mekanik',
      'Motor',
      'Şanzıman & Vites',
      'Yürüyen & Direksiyon',
    ],
    'Motorsiklet': [
      'Debriyaj',
      'Egzoz',
      'Elektrik',
      'Fren',
      'Grenaj',
      'Havalandırma',
      'Motor',
      'Süspansiyon',
      'Şanzıman',
      'Yağlama',
      'Yakıt Sistemi',
      'Yönlendirme',
    ],
    'Bisiklet': [
      'Gidon',
      'Fren',
      'Rotor',
      'Bilya',
      'Jant',
      'Kadro',
      'Çekiş Parçaları',
      'Elektrik Parçaları',
      'Kokpit',
      'Pabuç',
    ],
  };

  final Map<String, List<String>> vehicleBrands = {
    'Araba': [
      'Toyota',
      'Honda',
      'Ford',
      'BMW',
      'Mercedes',
    ],
    'Motorsiklet': [
      'Yamaha',
      'Honda',
      'Suzuki',
      'Kawasaki',
      'Ducati',
    ],
    'Bisiklet': [
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
        'partCategory': _selectedPartCategory, // Değişiklik yapıldı
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

      // Navigate back to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
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
        title: Text('Add Part'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_image != null) Image.file(_image!),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Select Image'),
            ),
            DropdownButton<String>(
              value: _selectedVehicleType,
              hint: Text('Select Vehicle Type'),
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
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text('Select Category'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    // Kategori seçildiğinde partCategory değişkenine seçilen kategori ekleniyor
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
              DropdownButton<String>(
                value: _selectedBrand,
                hint: Text('Select Brand'),
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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Year'),
            ),
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
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            ElevatedButton(
              onPressed: _savePart,
              child: Text('Save Part'),
            ),
          ],
        ),
      ),
    );
  }
}
