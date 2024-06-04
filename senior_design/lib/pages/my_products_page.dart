import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'edit_part_page.dart';

class MyProductsPage extends StatefulWidget {
  @override
  _MyProductsPageState createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late User _user;
  List<Map<String, dynamic>> _products = [];
  List<String> _productIds = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserProducts();
  }

  Future<void> _loadUserProducts() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${_user.uid}/products').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        final productIds = (snapshot.value as Map<dynamic, dynamic>).keys.toList();
        final List<Map<String, dynamic>> productList = [];
        for (var productId in productIds) {
          final productSnapshot = await _firestore.collection('parts').doc(productId).get();
          if (productSnapshot.exists) {
            final productData = productSnapshot.data() as Map<String, dynamic>;
            productData['id'] = productId;
            productList.add(productData);
            _productIds.add(productId);
          }
        }
        setState(() {
          _products = productList;
        });
      }
    } catch (e) {
      print('Error loading user products: $e');
    }
  }

  Future<void> _deleteProduct(String productId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    try {
      final productSnapshot = await _firestore.collection('parts').doc(productId).get();
      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        final imageUrl = productData['image_url'];
        if (imageUrl != null) {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      }

      await _firestore.collection('parts').doc(productId).delete();
      await _databaseRef.child('users/${_user.uid}/products/$productId').remove();
      _loadUserProducts();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _editProduct(String productId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPartPage(productId: productId),
      ),
    ).then((_) {
      _loadUserProducts();
    });
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
          title: Text('My Products Page',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: _products.isEmpty
          ? Center(
              child: Text(
                'No products found.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final productId = product['id'];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: product['image_url'] != null
                        ? Image.network(
                            product['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image);
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Icon(Icons.image),
                  ),
                  title: Text(product['title'] ?? 'No Title'),
                  subtitle: Text('Price: \$${product['price']?.toStringAsFixed(2) ?? 'N/A'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editProduct(productId);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(productId);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
