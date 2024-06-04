import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'other_user_products_page.dart';
import 'other_user_comments_page.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;

  OtherUserProfilePage({required this.userId});

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  String? profileImage;
  String displayName = 'Anonymous User';
  int productCount = 0;
  int commentCount = 0;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${widget.userId}').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          profileImage = snapshot.child('imageUrl').value as String?;
          displayName = snapshot.child('name').value as String? ?? 'Anonymous User';
        });
        _loadProductCount();
        _loadCommentCount();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadProductCount() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${widget.userId}/products').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          productCount = snapshot.children.length;
        });
      }
    } catch (e) {
      print('Error loading product count: $e');
    }
  }

  Future<void> _loadCommentCount() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${widget.userId}/receivedRatingsAndComments').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          commentCount = snapshot.children.length;
        });
      }
    } catch (e) {
      print('Error loading comment count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                child: GestureDetector(
                  onTap: () {
                    if (profileImage != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(profileImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 420.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text('Products'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserProductsPage(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.comment),
                    title: Text('Comments'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserCommentsPage(userId: widget.userId),
                        ),
                      );
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
