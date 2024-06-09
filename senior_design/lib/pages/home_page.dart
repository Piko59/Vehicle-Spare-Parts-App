import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'category_business_page.dart';
import 'fullscreen_page.dart';
import 'business_details_page.dart';
import 'category_page.dart';
import 'search_page.dart';
import 'all_businesses_page.dart'; // Yeni sayfa import edildi

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  LocationData? _currentLocation;
  late GoogleMapController mapController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 40),
          child: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFFF76CE),
                    Color(0xFFA3D8FF),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight, left: 8.0, right: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              ),
                              onChanged: (value) {
                              },
                              onSubmitted: (value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  )
                                );
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildNearbyBusinessesMap(),
              VehiclePartIcons(onCategorySelected: _navigateToCategoryPage),
              const PopularStores(),
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
              child: const Icon(Icons.warning, color: Colors.white),
              heroTag: 'emergency',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  List<String> businessCategories = [
    'Tire Shop',
    'Dent Repair',
    'Carburetor Repair',
    'Modification Shop',
    'Engine Repair',
    'Body Shop'
  ];

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Emergency Categories',
            style: TextStyle(
              fontSize: 24, // Başlık metnini büyük yap
              fontWeight: FontWeight.bold,
              color: Colors.red, // Kırmızı renk kullan
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                businessCategories.length,
                (index) => ListTile(
                  title: Text(
                    businessCategories[index],
                    style: TextStyle(
                      color: Colors.red, // Kırmızı renk kullan
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward, // Gitme ikonu
                    color: Colors.red, // Renk
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryBusinessesPage (
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Kırmızı renk kullan
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildNearbyBusinessesMap() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nearby Businesses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _currentLocation == null
                  ? const Center(child: CircularProgressIndicator())
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

  void _navigateToCategoryPage(String categoryType) {
    List<String> categories;
    switch (categoryType) {
      case 'Car':
        categories = [
          'Ignition & Fuel', 'Exhaust', 'Electrical', 'Filter', 'Brake & Clutch',
          'Mechanical', 'Engine', 'Transmission & Gear', 'Suspension & Steering',
        ];
        break;
      case 'Motorcycle':
        categories = [
          'Clutch', 'Exhaust', 'Electrical', 'Brake', 'Fairing', 'Ventilation', 'Engine',
          'Suspension', 'Transmission', 'Lubrication', 'Fuel System', 'Steering',
        ];
        break;
      case 'Bicycle':
        categories = [
          'Handlebar', 'Brake', 'Rotor', 'Bearing', 'Rim', 'Frame', 'Drivetrain Components',
          'Electric Components', 'Cockpit', 'Brake Pad',
        ];
        break;
      default:
        categories = [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          categoryType: categoryType,
          categories: categories,
        ),
      ),
    );
  }
}

class PopularStores extends StatefulWidget {
  const PopularStores({Key? key}) : super(key: key);

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
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('businesses');
      DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
      debugPrint('Fetched businesses snapshot: ${snapshot.value}');

      if (snapshot.exists) {
        List<Map<String, dynamic>> stores = [];
        Map<dynamic, dynamic> businesses = snapshot.value as Map<dynamic, dynamic>;
        debugPrint('Businesses data: $businesses');

        for (var businessUid in businesses.keys) {
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(businessUid);
          DataSnapshot userSnapshot = await userRef.once().then((event) => event.snapshot);
          debugPrint('Fetched user snapshot for $businessUid: ${userSnapshot.value}');

          if (userSnapshot.exists) {
            debugPrint('User snapshot exists for $businessUid');
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
            debugPrint('Added store: $name');
          } else {
            debugPrint('User snapshot for $businessUid does not exist');
          }
        }

        // Rating'e göre sıralama ve ilk 5 mağazayı alma
        stores.sort((a, b) => b['rating'].compareTo(a['rating']));
        stores = stores.take(5).toList();

        setState(() {
          _stores = stores;
          debugPrint('Stores list updated: $_stores');
        });
      } else {
        debugPrint('Businesses snapshot does not exist');
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Popular Stores',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllBusinessesPage()),
                  );
                },
                child: const Text('See All', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        Container(
          height: 150,
          child: _stores.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stores.length,
                  itemBuilder: (context, index) {
                    return StoreTile(
                      name: _stores[index]['name'],
                      imageUrl: _stores[index]['imageUrl'],
                      rating: _stores[index]['rating'],
                      businessUid: _stores[index]['businessUid'],
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

  const StoreTile({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.businessUid,
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
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(8),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
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
                style: const TextStyle(
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
  final Function(String) onCategorySelected;

  const VehiclePartIcons({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'Search Vehicles Part Spares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0XFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset('assets/car.png', width: 60, height: 60),
                onPressed: () {
                  onCategorySelected('Car');
                },
              ),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: const BoxDecoration(
                color: Color(0XFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset('assets/motorcycle.png', width: 60, height: 60),
                onPressed: () {
                  onCategorySelected('Motorcycle');
                },
              ),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: const BoxDecoration(
                color: Color(0XFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset('assets/bicycle.png', width: 60, height: 60),
                onPressed: () {
                  onCategorySelected('Bicycle');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
