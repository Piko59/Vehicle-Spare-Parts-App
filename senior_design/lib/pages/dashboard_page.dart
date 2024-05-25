import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/vehicle_part_icons.dart';
import '../widgets/popular_stores.dart';
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
                    // Handle emergency category selection
                    print('Selected category: ${businessCategories[index]}');
                    Navigator.pop(context); // Close the dialog
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

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
        });
      }
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(searchController: _searchController),
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
              icon: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPartScreen()),
                  );
                },
                child: Container(
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
              ),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

List<String> businessCategories = [
  'Lastikçi',
  'Göçükçü',
  'Karbüratörcü',
  'Modifiyeci',
  'Motor Arıza',
  'Kaportacı'
];
