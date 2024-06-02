import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:senior_design/pages/car_categories_page.dart';
import 'package:senior_design/pages/motorcycle_categories_page.dart';
import 'package:senior_design/pages/bicycle_categories_page.dart';
import 'business_list_page.dart';
import 'fullscreen_page.dart';
import 'business_details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _userName;
  LocationData? _currentLocation;
  late GoogleMapController mapController;

  List<String> businessCategories = [
    'Lastikçi',
    'Göçükçü',
    'Karbüratörcü',
    'Modifiyeci',
    'Motor Arıza',
    'Kaportacı'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _fetchUserName(user.uid);
        });
      }
    });
  }

  Future<void> _fetchUserName(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uid)
        .child('name');
    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
    if (snapshot.exists) {
      setState(() {
        _userName = snapshot.value as String?;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    Location location = new Location();
    LocationData _locationData;
    _locationData = await location.getLocation();
    setState(() {
      _currentLocation = _locationData;
    });
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Categories'),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                businessCategories.length,
                (index) => ListTile(
                  title: Text(businessCategories[index]),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusinessListPage(
                          category: businessCategories[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFullScreenMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FullscreenPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: SearchAppBar(
          searchController: _searchController,
          userName: _userName ?? 'Guest',
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNearbyBusinessesMap(),
              VehiclePartIcons(),
              PopularStores(),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                _showEmergencyDialog(context);
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.warning),
              heroTag: 'emergency',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyBusinessesMap() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearby Businesses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _currentLocation == null
                  ? Center(child: CircularProgressIndicator())
                  : GoogleMap(        
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_currentLocation!.latitude!,
                            _currentLocation!.longitude!),
                        zoom: 14.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      onTap: (LatLng position) {
                        _navigateToFullScreenMap(context);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}



class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final String userName;

  SearchAppBar(
      {Key? key, required this.searchController, required this.userName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF00A9B7),
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Welcome, $userName',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'What do you want?',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120.0);
}

class PopularStores extends StatefulWidget {
  @override
  _PopularStoresState createState() => _PopularStoresState();
}

class _PopularStoresState extends State<PopularStores> {
  List<Map<String, dynamic>> _stores = [];

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('businesses');
    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
    print('Fetched businesses snapshot: ${snapshot.value}');

    if (snapshot.exists) {
      List<Map<String, dynamic>> stores = [];
      Map<dynamic, dynamic> businesses = snapshot.value as Map<dynamic, dynamic>;
      print('Businesses data: $businesses');

      for (var businessUid in businesses.keys) {
        DatabaseReference userRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(businessUid);
        DataSnapshot userSnapshot = await userRef.once().then((event) => event.snapshot);
        print('Fetched user snapshot for $businessUid: ${userSnapshot.value}');

        if (userSnapshot.exists) {
          print('User snapshot exists for $businessUid');
          Map<dynamic, dynamic> userData = userSnapshot.value as Map<dynamic, dynamic>;

          String name = userData['name'] ?? 'Unknown';
          String imageUrl = userData['imageUrl'] ?? 'https://via.placeholder.com/150';
          double rating = userData['averageRating'] != null ? double.parse(userData['averageRating'].toString()) : 0.0;
          String category = userData['category'] ?? 'Unknown';
          String phoneNumber = userData['phoneNumber'] ?? 'Unknown';

          stores.add({
            'name': name,
            'imageUrl': imageUrl,
            'rating': rating,
            'businessUid': businessUid,
            'category': category,
            'phoneNumber': phoneNumber,
          });
          print('Added store: $name');
        } else {
          print('User snapshot for $businessUid does not exist');
        }
      }

      setState(() {
        _stores = stores;
        print('Stores list updated: $_stores');
      });
    } else {
      print('Businesses snapshot does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Popular Stores',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: _stores.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stores.length,
                  itemBuilder: (context, index) {
                    return StoreTile(
                      name: _stores[index]['name'],
                      imageUrl: _stores[index]['imageUrl'],
                      rating: _stores[index]['rating'],
                      businessUid: _stores[index]['businessUid'],
                      businessCategory: _stores[index]['category'],
                      businessPhoneNumber: _stores[index]['phoneNumber'],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class StoreTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double rating;
  final String businessUid;
  final String businessCategory;
  final String businessPhoneNumber;

  const StoreTile({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.businessUid,
    required this.businessCategory,
    required this.businessPhoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDetailsPage(
              businessUid: businessUid,
              businessName: name,
              businessImageUrl: imageUrl,
              businessCategory: businessCategory,
              businessPhoneNumber: businessPhoneNumber,
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.all(8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class VehiclePartIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Search Vehicles Part Spares',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0XFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset('assets/car.png', width: 70, height: 70),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CarCategoriesPage()));
                },
              ),
            ),
            SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0XFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset('assets/motorcycle.png', width: 70, height: 70),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MotorcycleCategoriesPage()));
                },
              ),
            ),
            SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0XFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset('assets/bicycle.png', width: 70, height: 70),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BicycleCategoriesPage()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
