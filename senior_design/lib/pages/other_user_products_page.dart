import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'part_details_screen.dart';

class OtherUserProductsPage extends StatefulWidget {
  final String userId;

  OtherUserProductsPage({required this.userId});

  @override
  _OtherUserProductsPageState createState() => _OtherUserProductsPageState();
}

class _OtherUserProductsPageState extends State<OtherUserProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _products = [];
  List<String> _productIds = [];

  @override
  void initState() {
    super.initState();
    _loadUserProducts();
  }

  Future<void> _loadUserProducts() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${widget.userId}/products').once();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PartDetailScreen(
                          title: product['title'],
                          imageUrl: product['image_url'],
                          description: product['description'],
                          price: product['price'],
                          brand: product['brand'],
                          isNew: product['isNew'],
                          year: product['year'],
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
