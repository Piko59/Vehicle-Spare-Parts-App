import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_design/pages/part_details_screen.dart';

class CategoryDetailPage extends StatelessWidget {
  final String category;
  final String partCategory;

  CategoryDetailPage({required this.category, required this.partCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Kategorisi - $partCategory'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parts')
            .where('vehicle_type', isEqualTo: category)
            .where('category', isEqualTo: partCategory)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu!'));
          }

          final parts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: parts.length,
            itemBuilder: (context, index) {
              final part = parts[index];
              return ListTile(
                leading: Image.network(
                  part['image_url'],
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(part['title']),
                subtitle: Text('Price: \$${part['price']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartDetailScreen(
                        title: part['title'],
                        imageUrl: part['image_url'],
                        description: part['description'],
                        price: part['price'].toDouble(),
                        brand: part['brand'],
                        isNew: part['isNew'],
                        year: part['year'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
