import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'other_user_products_page.dart';
import 'business_comments_page.dart';
import 'chat_page.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessUid;

  BusinessDetailsPage({required this.businessUid});

  @override
  _BusinessDetailsPageState createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  double _averageRating = 0.0;
  String _businessName = '';
  String? _businessImageUrl;
  String _businessCategory = '';
  String _businessPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
    _fetchAverageRating();
  }

  void _fetchBusinessDetails() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    DatabaseEvent event = await databaseReference
        .child('users')
        .child(widget.businessUid)
        .once();

    if (event.snapshot.value != null) {
      setState(() {
        var data = event.snapshot.value as Map;
        _businessName = data['name'] ?? '';
        _businessImageUrl = data['imageUrl'];
        _businessCategory = data['businessCategory'] ?? '';
        _businessPhoneNumber = data['phoneNumber'] ?? '';
      });
    }
  }

  void _fetchAverageRating() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    DatabaseEvent event = await databaseReference
        .child('users')
        .child(widget.businessUid)
        .child('averageRating')
        .once();

    if (event.snapshot.value != null) {
      setState(() {
        _averageRating = (event.snapshot.value as num).toDouble();
      });
    }
  }

  void _launchPhoneDialer(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> handleSendMessage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    if (currentUser.uid == widget.businessUid) {
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

        if (participants.containsKey(widget.businessUid)) {
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
        widget.businessUid: true,
      },
      'messages': {},
    });

    await FirebaseDatabase.instance.ref('users/$currentUserId/conversations/$newConversationId').set(true);
    await FirebaseDatabase.instance.ref('users/${widget.businessUid}/conversations/$newConversationId').set(true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(conversationId: newConversationId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Business',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 300.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF76CE),
                        Color(0xFFA3D8FF)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16.0,
              right: 16.0,
              top: 200.0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    Text(
                      _businessName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _businessCategory,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchPhoneDialer(_businessPhoneNumber),
                      child: Text(
                        'Phone: $_businessPhoneNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 120),
                child: GestureDetector(
                  onTap: () {
                    if (_businessImageUrl != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(_businessImageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 5),
                      image: _businessImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_businessImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        _businessImageUrl == null
                            ? const Center(
                                child: Icon(
                                  Icons.business,
                                  size: 150,
                                  color: Colors.grey,
                                ),
                              )
                            : Container(),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  _averageRating.toStringAsFixed(1),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 410.0),
              child: Center(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProductsPage(
                                      userId: widget.businessUid)),
                            );
                          },
                          child: const Text(
                            'Products',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BusinessCommentsPage(
                                      businessUid: widget.businessUid)),
                            );
                          },
                          child: const Text(
                            'Comments',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: handleSendMessage,
          child: Icon(Icons.chat, color: Colors.white),
          backgroundColor: Color(0xFFFF76CE),
      ),
    );
  }
}
