import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/user_manager.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('users');
  final _formKey = GlobalKey<FormState>();
  bool _isBusiness = false;

  // Personal fields
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _address = '';
  String _profileImage = '';

  // Business fields
  String _businessName = '';
  String _businessCategory = 'Lastikçi'; // Default category set
  String _businessPhoneNumber = '';
  String _businessAddress = '';
  String _businessImage = '';

  List<String> businessCategories = [
    'Lastikçi',
    'Göçükçü',
    'Karbüratörcü',
    'Modifiyeci',
    'Motor Arıza',
    'Kaportacı'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SwitchListTile(
                title: Text('Are you a business owner?'),
                value: _isBusiness,
                onChanged: (bool value) {
                  setState(() {
                    _isBusiness = value;
                  });
                },
              ),
              if (!_isBusiness) ...[
                _buildTextInput('First Name', (value) => _firstName = value),
                _buildTextInput('Last Name', (value) => _lastName = value),
                _buildTextInput(
                    'Phone Number', (value) => _phoneNumber = value),
                _buildTextInput(
                    'Address (City / District)', (value) => _address = value),
                _buildImageInput('Profile Image', (url) => _profileImage = url),
              ] else ...[
                _buildTextInput(
                    'Business Name', (value) => _businessName = value),
                _buildBusinessCategoryDropdown(),
                _buildTextInput('Business Phone Number',
                    (value) => _businessPhoneNumber = value),
                _buildTextInput('Business Address (City / District)',
                    (value) => _businessAddress = value),
                _buildImageInput(
                    'Business Image', (url) => _businessImage = url),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildImageInput(String label, Function(String) onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: () => _pickAndUploadImage(label, onSaved),
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
          text: label.contains('Profile') ? _profileImage : _businessImage),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please upload an image';
        }
        return null;
      },
    );
  }

  Widget _buildBusinessCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _businessCategory,
      decoration: InputDecoration(labelText: 'Business Category'),
      items: businessCategories
          .map((String category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _businessCategory = newValue!;
        });
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please select a business category';
        }
        return null;
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      String? userId = UserManager.currentUserId;
      if (userId != null) {
        Map<String, dynamic> profileData = {
          'profileType': _isBusiness ? 'business' : 'personal',
          'profile': _isBusiness
              ? {
                  'businessName': _businessName,
                  'businessCategory': _businessCategory,
                  'phoneNumber': _businessPhoneNumber,
                  'address': _businessAddress,
                  'businessImage': _businessImage,
                  'rating': 0, // Başlangıç değeri olarak 0 verilmiştir.
                }
              : {
                  'firstName': _firstName,
                  'lastName': _lastName,
                  'phoneNumber': _phoneNumber,
                  'address': _address,
                  'profileImage': _profileImage,
                },
        };
        _databaseReference.child(userId).update(profileData).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated successfully')));
          Navigator.pop(context);
        }).catchError((error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $error')));
        });
      }
    }
  }

  Future<void> _pickAndUploadImage(
      String label, Function(String) onSaved) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        String? userId = UserManager.currentUserId;
        String imageType = label.contains('Profile') ? 'profile' : 'business';
        String filePath =
            'user_images/$userId/$imageType/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await FirebaseStorage.instance.ref(filePath).putFile(file);
        String downloadURL =
            await FirebaseStorage.instance.ref(filePath).getDownloadURL();
        setState(() {
          onSaved(downloadURL);
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
}
