import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'add_part_page.dart';
import 'conversations_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index != 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _onFabPressed() async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPartPage()),
    );

    if (result == true) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      HomePage(),
      ExplorePage(),
      Container(),
      ConversationsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        selectedIconTheme: IconThemeData(size: 32.0),
        unselectedIconTheme: IconThemeData(size: 24.0),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Container(width: 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFF0080),
        unselectedItemColor: Color(0xFFBDBDBD),
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70.0,
        height: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _onFabPressed,
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Color(0xFF5BBCFF),
          ),
        ),
      ),
    );
  }
}
