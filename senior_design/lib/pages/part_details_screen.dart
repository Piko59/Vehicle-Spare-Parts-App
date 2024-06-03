import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';

class PartDetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  final String brand;
  final bool isNew;
  final int year;
  final String userId;

  PartDetailScreen({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.brand,
    required this.isNew,
    required this.year,
    required this.userId,
  });

  @override
  _PartDetailScreenState createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('users').child(widget.userId);
    DatabaseEvent event = await ref.once();

    if (event.snapshot.value != null) {
      setState(() {
        userName = (event.snapshot.value as Map)['name'];
      });
    }
  }

  Future<void> handleSendMessage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Kullanıcı giriş yapmamışsa, giriş yapma sayfasına yönlendirme yapılabilir
      return;
    }

    if (currentUser.uid == widget.userId) {
      // Ürün sahibi kullanıcı ile aynıysa, dialog göster
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Notice"),
            content: Text("This product already belongs to you."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    String currentUserId = currentUser.uid;
    DatabaseReference userConversationsRef = FirebaseDatabase.instance.ref('users/$currentUserId/conversations');

    DatabaseEvent userConversationsEvent = await userConversationsRef.once();
    if (userConversationsEvent.snapshot.value != null) {
      Map conversations = userConversationsEvent.snapshot.value as Map;
      for (String conversationId in conversations.keys) {
        DatabaseReference conversationRef = FirebaseDatabase.instance.ref('conversations/$conversationId/participants');
        DatabaseEvent conversationEvent = await conversationRef.once();
        Map participants = conversationEvent.snapshot.value as Map;

        if (participants.containsKey(widget.userId)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(conversationId: conversationId)),
          );
          return;
        }
      }
    }

    // Eğer mevcut bir konuşma yoksa yeni bir konuşma oluştur
    DatabaseReference newConversationRef = FirebaseDatabase.instance.ref('conversations').push();
    String newConversationId = newConversationRef.key!;
    await newConversationRef.set({
      'participants': {
        currentUserId: true,
        widget.userId: true,
      },
      'messages': {},
    });

    await FirebaseDatabase.instance.ref('users/$currentUserId/conversations/$newConversationId').set(true);
    await FirebaseDatabase.instance.ref('users/$widget.userId/conversations/$newConversationId').set(true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(conversationId: newConversationId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Part Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF00A9B7),
        iconTheme: IconThemeData(color: Colors.white),
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                widget.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.price.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Brand:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.brand, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Is New:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.isNew.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Year:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.year.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Owner:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF76CE),
                    Color(0xFFA3D8FF),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: InkWell(
                onTap: handleSendMessage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Center(
                    child: Text(
                      'Send Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
