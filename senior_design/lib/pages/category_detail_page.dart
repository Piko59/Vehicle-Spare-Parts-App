import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_design/pages/part_detail_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final String category;
  final String partCategory;

  CategoryDetailPage({required this.category, required this.partCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00A9B7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$category Category - $partCategory',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            return Center(child: Text('An error occurred!'));
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
                title: Text(
                  part['title'],
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Price: \$${part['price']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartDetailPage(
                        title: part['title'],
                        imageUrl: part['image_url'],
                        description: part['description'],
                        price: part['price'].toDouble(),
                        brand: part['brand'],
                        isNew: part['isNew'],
                        year: part['year'],
                        userId: part['user_id'],
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
