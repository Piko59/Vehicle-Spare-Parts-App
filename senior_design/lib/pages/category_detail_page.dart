import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDetailPage extends StatelessWidget {
  final String category;
  final String partCategory;

  CategoryDetailPage({required this.category, required this.partCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category / $partCategory'), // Sayfanın başlığı
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parts')
            .where('vehicle_type', isEqualTo: category)
            .where('category', isEqualTo: partCategory)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No parts found for this category.'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: Image.network(data['image_url']), // İlanın resmi
                  title: Text(
                    data['title'], // İlanın başlığı
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${data['price']}'), // İlanın fiyatı
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
