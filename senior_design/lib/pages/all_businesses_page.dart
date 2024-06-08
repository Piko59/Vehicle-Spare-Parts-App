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
          title: Text(
            'All Businesses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: _stores.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: _stores.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
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
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                                child: Image.network(
                                  _stores[index]['imageUrl'],
                                  height: MediaQuery.of(context).size.width / 2,
                                  width: MediaQuery.of(context).size.width / 2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _stores[index]['name'],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      _stores[index]['businessCategory'],
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16.0),
                                  SizedBox(width: 4.0),
                                  Text(
                                    _stores[index]['rating'].toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
