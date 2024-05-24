import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'add_part_screen.dart';
import 'conversations_page.dart';
import '../utils/user_manager.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    String? userId = UserManager.currentUserId;
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }
    else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPartScreen()),
      );
    }
    else if (index == 3) {
      if (userId != null) {
        // Kullanıcı ID'si mevcutsa ve null değilse ConversationsPage'e yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConversationsPage(userId: userId)),
        );
      } else {
        // Kullanıcı ID'si null ise hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to view conversations."))
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('My Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF00A9B7),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Color(0xFF00A9B7),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage('assets/emre.png'),
                  radius: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Emre Semiz',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'App Developer',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildStatCard('Total order', '243'),
                    _buildStatCard('Comments', '89'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildMenuButton(context, Icons.shopping_cart, 'My Orders', DashboardPage()),
                _buildMenuButton(context, Icons.settings, 'Settings', DashboardPage()),
                _buildMenuButton(context, Icons.exit_to_app, 'Log Out', LoginPage()),
              ],
            ),
          ),
        ],
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
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
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

  Widget _buildStatCard(String title, String count) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String title, Widget page) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 72.0), // İstatistik kartlarıyla aynı padding
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
