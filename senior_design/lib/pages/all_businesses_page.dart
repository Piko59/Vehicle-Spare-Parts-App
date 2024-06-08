import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'business_details_page.dart';

class AllBusinessesPage extends StatefulWidget {
  @override
  _AllBusinessesPageState createState() => _AllBusinessesPageState();
}

class _AllBusinessesPageState extends State<AllBusinessesPage> {
  List<Map<String, dynamic>> _stores = [];

  @override
  void initState() {
    super.initState();
    _fetchAllStores();
  }

  Future<void> _fetchAllStores() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('businesses');
      DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

      if (snapshot.exists) {
        List<Map<String, dynamic>> stores = [];
        Map<dynamic, dynamic> businesses = snapshot.value as Map<dynamic, dynamic>;

        for (var businessUid in businesses.keys) {
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(businessUid);
          DataSnapshot userSnapshot = await userRef.once().then((event) => event.snapshot);

          if (userSnapshot.exists) {
            Map<dynamic, dynamic> userData = userSnapshot.value as Map<dynamic, dynamic>;

            String name = userData['name'] ?? 'Unknown';
            String imageUrl = userData['imageUrl'] ?? 'https://via.placeholder.com/150';
            double rating = userData['averageRating'] != null ? double.parse(userData['averageRating'].toString()) : 0.0;
            String businessCategory = userData['businessCategory'] ?? 'Unknown';
            String phoneNumber = userData['phoneNumber'] ?? 'Unknown';

            stores.add({
              'name': name,
              'imageUrl': imageUrl,
              'rating': rating,
              'businessUid': businessUid,
              'businessCategory': businessCategory,
              'phoneNumber': phoneNumber,
            });
          }
        }

        // Sort stores by average rating in descending order
        stores.sort((a, b) => b['rating'].compareTo(a['rating']));

        setState(() {
          _stores = stores;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    }
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
          title: Text('All Businesses',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Container(
        child: _stores.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _stores.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(_stores[index]['imageUrl'], width: 50, height: 50),
                    title: Text(_stores[index]['name']),
                    subtitle: Text(_stores[index]['businessCategory']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(_stores[index]['rating'].toStringAsFixed(1)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessDetailsPage(
                            businessUid: _stores[index]['businessUid'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
