import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'select_location_page.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('users');
  final _formKey = GlobalKey<FormState>();
  bool _isBusiness = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _businessCategory = 'Tire Shop';
  LatLng? _businessLocation;

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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DataSnapshot snapshot = await _databaseReference.child(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _isBusiness = userData['profileType'] == 'business';
          _nameController.text = userData['name'];
          _phoneNumberController.text = userData['phoneNumber'];
          if (userData.containsKey('location')) {
            _businessLocation = LatLng(
              userData['location']['latitude'],
              userData['location']['longitude'],
            );
            _locationController.text =
                '${_businessLocation!.latitude}, ${_businessLocation!.longitude}';
          }
          if (_isBusiness) {
            _businessCategory = userData['businessCategory'] ?? 'Tire Shop';
            if (!businessCategories.contains(_businessCategory)) {
              _businessCategory = 'Tire Shop';
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectLocation() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationPage()),
    );

    if (selectedLocation != null) {
      setState(() {
        _businessLocation = selectedLocation;
        _locationController.text =
            '${_businessLocation!.latitude}, ${_businessLocation!.longitude}';
      });
    }
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
              _buildTextInput(_isBusiness ?
               'Business Name' : 'Name', _nameController),
              _buildTextInput(_isBusiness ?
               'Business Phone Number' : 'Phone Number', _phoneNumberController, isPhoneNumber: true),
              if (_isBusiness) ...[
                _buildBusinessCategoryDropdown(),
              ],
              _buildLocationSelector(_isBusiness ? 'Business Location' : 'Location'),
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

Widget _buildTextInput(String label, TextEditingController controller, {bool isPhoneNumber = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: isPhoneNumber ? TextInputType.phone : TextInputType.text,
      inputFormatters: isPhoneNumber
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        } else if (label.contains('Name') && value.length > 18) {
          return '$label cannot be more than 18 characters';
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

  Widget _buildLocationSelector(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _locationController,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: _selectLocation,
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        Map<String, dynamic> profileData = {
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'profileType': _isBusiness ? 'business' : 'personal',
          'location': {
            'latitude': _businessLocation!.latitude,
            'longitude': _businessLocation!.longitude,
          },
        };

        if (_isBusiness) {
          profileData['businessCategory'] = _businessCategory;
        }

        _databaseReference.child(userId).update(profileData).then((_) {
          if (_isBusiness) {
            FirebaseDatabase.instance.reference().child('businesses').child(userId).set(true);
          } else {
            FirebaseDatabase.instance.reference().child('businesses').child(userId).remove();
          }

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
