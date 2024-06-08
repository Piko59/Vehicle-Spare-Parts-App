import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'business_details_page.dart';

class CategoryBusinessesPage extends StatefulWidget {
  final String category;

  const CategoryBusinessesPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryBusinessesPageState createState() => _CategoryBusinessesPageState();
}

class _CategoryBusinessesPageState extends State<CategoryBusinessesPage> {
  List<Map<String, dynamic>> _businesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBusinessesByCategory();
  }

  Future<void> _fetchBusinessesByCategory() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('businesses');
      DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

      if (snapshot.exists) {
        List<Map<String, dynamic>> businesses = [];
        Map<dynamic, dynamic> businessIds = snapshot.value as Map<dynamic, dynamic>;

        for (var businessId in businessIds.keys) {
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(businessId);
          DataSnapshot userSnapshot = await userRef.once().then((event) => event.snapshot);

          if (userSnapshot.exists) {
            Map<dynamic, dynamic> userData = userSnapshot.value as Map<dynamic, dynamic>;

            if (userData['businessCategory'] == widget.category) {
              businesses.add({
                'name': userData['name'] ?? 'Unknown',
                'imageUrl': userData['imageUrl'] ?? 'https://via.placeholder.com/150',
                'rating': userData['averageRating'] != null ? double.parse(userData['averageRating'].toString()) : 0.0,
                'businessUid': businessId,
                'businessCategory': userData['businessCategory'] ?? 'Unknown',
                'phoneNumber': userData['phoneNumber'] ?? 'Unknown',
              });
            }
          }
        }

        businesses.sort((a, b) => b['rating'].compareTo(a['rating']));

        setState(() {
          _businesses = businesses;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching businesses: $e');
      setState(() {
        _isLoading = false;
      });
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
            '${widget.category} Businesses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _businesses.isEmpty
                ? Center(
                    child: Text(
                      'Business not found',
                      style: TextStyle(fontSize: 18.0, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _businesses.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessDetailsPage(
                                businessUid: _businesses[index]['businessUid'],
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
                                      _businesses[index]['imageUrl'] ?? 'https://via.placeholder.com/150',
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
                                          _businesses[index]['name'] ?? 'Unknown',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          _businesses[index]['businessCategory'] ?? 'Unknown',
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
                                        (_businesses[index]['rating'] ?? 0.0).toStringAsFixed(1),
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
