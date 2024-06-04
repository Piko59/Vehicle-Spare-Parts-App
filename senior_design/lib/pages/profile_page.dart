import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImage;
  String displayName = 'Anonymous User';
  int productCount = 0;
  int commentCount = 0;
  File? _imageFile;
  final picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${_user.uid}').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          profileImage = snapshot.child('imageUrl').value as String?;
          displayName = snapshot.child('name').value as String? ?? 'Anonymous User';
          productCount = snapshot.child('productCount').value as int? ?? 0;
          commentCount = snapshot.child('commentCount').value as int? ?? 0;
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
      _updateImageURL(downloadURL);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _updateImageURL(String downloadURL) async {
    try {
      await _databaseRef.child('users/${_user.uid}').update({'imageUrl': downloadURL});
      print('Profile image URL updated successfully.');
    } catch (e) {
      print('Error updating profile image URL: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
    _loadUserProfile();  // EditProfilePage'den döndükten sonra kullanıcı profilini tekrar yükle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.camera_alt, color: Colors.white),
          onPressed: () {
            _pickImage();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              _navigateToEditProfile();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 300.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF76CE),
                        Color(0xFFA3D8FF)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16.0,
              right: 16.0,
              top: 200.0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              productCount.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              commentCount.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 130),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImage != null ? NetworkImage(profileImage!) : null,
                  child: profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 420.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Edit Profile'),
                    onTap: () {
                      _navigateToEditProfile();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text('My Products'),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.comment),
                    title: Text('Comments'),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Help & Support'),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip),
                    title: Text('Privacy Policy'),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sign Out'),
                    onTap: () {
                      _signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
