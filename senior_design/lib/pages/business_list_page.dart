import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BusinessListPage extends StatelessWidget {
  final String category;

  BusinessListPage({required this.category});

  Future<List<Map<String, dynamic>>> _getBusinessesByCategory(
      String category) async {
    List<Map<String, dynamic>> businesses = [];
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.reference().child('users');
      DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
      Map<dynamic, dynamic>? users = snapshot.value as Map<dynamic, dynamic>?;

      if (users != null) {
        users.forEach((key, value) {
          var profile = value['profile'];
          if (profile != null && profile['businessCategory'] == category) {
            Map<String, dynamic> businessInfo = {
              'name': profile['businessName'] ?? '',
              'image': profile['businessImage'] ?? '',
              'address': profile['address'] ?? '',
              'rating': profile['rating'] ?? 0,
            };
            businesses.add(businessInfo);
          }
        });
      }
    } catch (e) {
      print("Error: $e");
    }
    return businesses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Businesses'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getBusinessesByCategory(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No businesses found for this category.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var business = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: business['image'] != ''
                        ? Image.network(business['image'],
                            width: 60, height: 60, fit: BoxFit.cover)
                        : Icon(Icons.business, size: 60),
                    title: Text(
                      business['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(business['address']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        Text(business['rating'].toString()),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}