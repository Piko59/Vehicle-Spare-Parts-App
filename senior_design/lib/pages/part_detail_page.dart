import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'business_details_page.dart';

class PartDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  final String brand;
  final bool isNew;
  final int year;
  final String userId;

  PartDetailPage({
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
  _PartDetailPageState createState() => _PartDetailPageState();
}

class _PartDetailPageState extends State<PartDetailPage> {
  String userName = '';
  int selectedTabIndex = 0;

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
      return;
    }

    if (currentUser.uid == widget.userId) {
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
    await FirebaseDatabase.instance.ref('users/${widget.userId}/conversations/$newConversationId').set(true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(conversationId: newConversationId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Part Detail',
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
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    child: Image.network(
                      widget.imageUrl,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '\$${widget.price.toString()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          widget.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 0;
                              });
                            },
                            child: Text(
                              'Part Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: selectedTabIndex == 0 ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 1;
                              });
                            },
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: selectedTabIndex == 1 ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      selectedTabIndex == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Brand', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(widget.brand, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(widget.isNew ? 'New' : 'Secondhand', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Year', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(widget.year.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                widget.description,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, bottom: 16),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusinessDetailsPage(businessUid: widget.userId)),
                );
              },
              child: Icon(Icons.person, color: Colors.white),
              backgroundColor: Color(0xFFFF76CE),
              heroTag: 'personFab',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16, bottom: 16),
            child: FloatingActionButton(
              onPressed: handleSendMessage,
              child: Icon(Icons.chat, color: Colors.white),
              backgroundColor: Color(0xFFFF76CE),
              heroTag: 'chatFab',
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
