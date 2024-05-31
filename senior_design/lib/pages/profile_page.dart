import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'edit_profile_page.dart';
import '../utils/user_manager.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImage;
  String displayName = 'Anonymous User';
  File? _imageFile;
  final picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  final String userId =
      UserManager.currentUserId ?? ''; // Kullanıcı ID'sini alıyoruz.

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final DatabaseEvent event =
          await _databaseRef.child('users/$userId').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          profileImage = snapshot.child('imageUrl').value
              as String?; // null by default
          displayName =
              snapshot.child('name').value as String? ?? 'Anonymous User';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _uploadImageToStorage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImageToStorage() async {
    if (_imageFile == null) return;
    String fileName = path.basename(_imageFile!.path);
    Reference storageRef = _storage.ref().child('profile_images/$fileName');

    try {
      await storageRef.putFile(_imageFile!);
      String downloadURL = await storageRef.getDownloadURL();
      setState(() {
        profileImage = downloadURL;
      });
      _updateImageURL(downloadURL); // Profil resim URL'sini güncelle
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _updateImageURL(String downloadURL) async {
    try {
      await _databaseRef
          .child('users/$userId')
          .update({'imageUrl': downloadURL});
      print('Profile image URL updated successfully.');
    } catch (e) {
      print('Error updating profile image URL: $e');
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: profileImage != null
              ? NetworkImage(profileImage!)
              : AssetImage('assets/default_user_image.jpg'),
          radius: 95,
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: _pickImage,
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF00A9B7),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Color(0xFF00A9B7),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              children: <Widget>[
                _buildProfileImage(),
                SizedBox(height: 10),
                Text(
                  displayName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildStatCard('Total order', '243'),
                    _buildStatCard('Comments', '89'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildMenuButton(context, 'My Orders', HomePage()),
                _buildMenuButton(context, 'Settings', HomePage()),
                _buildMenuButton(context, 'Log Out', LoginPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget page) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 72.0),
      child: ListTile(
        title: Text(title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
