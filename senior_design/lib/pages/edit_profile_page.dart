import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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

  // Common fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Business specific field
  String _businessCategory = 'Tire Shop'; // Default category set

  List<String> businessCategories = [
    'Tire Shop',
    'Dent Repair',
    'Carburetor Repair',
    'Modification Shop',
    'Engine Repair',
    'Body Shop'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    String? userId = UserManager.currentUserId;
    if (userId != null) {
      DataSnapshot snapshot = await _databaseReference.child(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _isBusiness = userData['profileType'] == 'business';
          _nameController.text = userData['name'];
          _usernameController.text = userData['username']; // Veritabanından username'i al
          _phoneNumberController.text = userData['phoneNumber'];
          _addressController.text = userData['address'];
          if (_isBusiness) {
            _businessCategory = userData['businessCategory'];
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF00A9B7),
        iconTheme: IconThemeData(color: Colors.white),
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
                _buildTextInput('Name', _nameController),
                _buildTextInput('Username', _usernameController),
                _buildTextInput('Phone Number', _phoneNumberController),
                _buildTextInput('Address (City / District)', _addressController),
              ] else ...[
                _buildTextInput('Business Name', _nameController),
                _buildBusinessCategoryDropdown(),
                _buildTextInput('Business Phone Number', _phoneNumberController),
                _buildTextInput('Business Address (City / District)', _addressController),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00A9B7),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
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

  Widget _buildBusinessCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _businessCategory,
        decoration: InputDecoration(
          labelText: 'Business Category',
          border: OutlineInputBorder(),
        ),
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
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      String? userId = UserManager.currentUserId;
      if (userId != null) {
        Map<String, dynamic> profileData = {
          'name': _nameController.text,
          'username': _usernameController.text,
          'phoneNumber': _phoneNumberController.text,
          'profileType': _isBusiness ? 'business' : 'personal',
          'address': _addressController.text,
        };

        if (_isBusiness) {
          profileData['businessCategory'] = _businessCategory;
        }

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
}
