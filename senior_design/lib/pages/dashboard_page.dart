import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:senior_design/pages/car_categories_page.dart';
import 'package:senior_design/pages/motorcycle_categories_page.dart';
import 'package:senior_design/pages/bicycle_categories_page.dart';
import 'add_part_screen.dart';
import 'profile_page.dart';
import 'conversations_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String? _currentUserId;
  String? _userName;

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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
          _fetchUserName(user.uid);
        });
      }
    });
  }

  Future<void> _fetchUserName(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('users').child(uid).child('name');
    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
    if (snapshot.exists) {
      setState(() {
        _userName = snapshot.value as String?;
      });
    }
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
                    Navigator.pop(context); // Close the dialog
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
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPartScreen()),
      );
    } else if (index == 3) {
      if (_currentUserId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationsPage(userId: _currentUserId!)),
        );
      } else {
        // Handle error or inform user to login
        print('User not logged in');
      }
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
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
              VehiclePartIcons(),
              PopularStores(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showEmergencyDialog(context);
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.warning),
        ),
        bottomNavigationBar: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF00A9B7),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 10.0,
            unselectedFontSize: 10.0,
            iconSize: 28.0,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.explore), label: 'Explore'),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

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

class PopularStores extends StatelessWidget {
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
              Text('Popular Stores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              StoreTile(
                name: 'Kaportacı Emre Usta',
                distance: '1.7 km',
                imageUrl: 'assets/kaportaci1.jpg',
                rating: 4.5,
                reviews: 744
              ),
              StoreTile(
                name: 'Semizler Kardeş Servis',
                distance: '1.9 km',
                imageUrl: 'assets/kaportaci2.jpg',
                rating: 4.5,
                reviews: 744
              ),
              // Daha fazla StoreTile widget'ı eklenebilir
            ],
          ),
        ),
      ],
    );
  }
}

// AppBar widget'ı
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final String userName;

  SearchAppBar({Key? key, required this.searchController, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF00A9B7),
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Welcome, $userName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset('assets/map_placeholder.png', fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(360.0);
}

class StoreTile extends StatelessWidget {
  final String name;
  final String distance;
  final String imageUrl;
  final double rating;
  final int reviews;

  const StoreTile({Key? key, required this.name, required this.distance, required this.imageUrl, required this.rating, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(imageUrl, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.blue, size: 20),
              SizedBox(width: 4),
              Text('$rating($reviews)', style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 4),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(distance),
        ],
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
            IconButton(
              icon: Icon(Icons.directions_car, size: 50),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CarCategoriesPage()));
              },
            ),
            SizedBox(width: 20),
            IconButton(
              icon: Icon(Icons.directions_bike, size: 50),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BicycleCategoriesPage()));
              },
            ),
            SizedBox(width: 20),
            IconButton(
              icon: Icon(Icons.motorcycle, size: 50),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MotorcycleCategoriesPage()));
              },
            ),
          ],
        ),
      ],
    );
  }
}
