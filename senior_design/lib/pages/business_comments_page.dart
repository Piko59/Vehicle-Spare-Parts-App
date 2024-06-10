import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'add_comment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessCommentsPage extends StatefulWidget {
  final String businessUid;

  BusinessCommentsPage({required this.businessUid});

  @override
  _BusinessCommentsPageState createState() => _BusinessCommentsPageState();
}

class _BusinessCommentsPageState extends State<BusinessCommentsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  String formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy HH:mm').format(date);
  }

  Future<bool> _checkIfUserHasCommented() async {
    DataSnapshot snapshot = await _databaseRef
        .child('users')
        .child(widget.businessUid)
        .child('receivedComments')
        .get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> receivedComments = snapshot.value as Map<dynamic, dynamic>;
      for (var commentId in receivedComments.keys) {
        DataSnapshot commentSnapshot = await _databaseRef.child('Comments').child(commentId).get();
        if (commentSnapshot.exists) {
          Map<dynamic, dynamic> commentData = commentSnapshot.value as Map<dynamic, dynamic>;
          if (commentData['userId'] == _currentUser!.uid) {
            return true;
          }
        }
      }
    }

    return false;
  }

  void _navigateToAddCommentPage() async {
    if (_currentUser != null && _currentUser.uid == widget.businessUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This business belongs to you')),
      );
      return;
    }

    bool hasCommented = await _checkIfUserHasCommented();
    if (!hasCommented) {
      bool result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddCommentPage(businessUid: widget.businessUid)),
      );
      if (result == true) {
        setState(() {});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already commented on this business.')),
      );
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
          title: Text('Business Comments',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<DataSnapshot>(
                  future: _databaseRef.child('users').child(widget.businessUid).child('receivedComments').get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot dataSnapshot = snapshot.data!;
                      if (dataSnapshot.value != null) {
                        Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;
                        List<dynamic> commentIds = data.keys.toList()
                          ..sort((a, b) => a.compareTo(b));

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: commentIds.length,
                          itemBuilder: (context, index) {
                            String commentId = commentIds[index];

                            return FutureBuilder<DataSnapshot>(
                              future: _databaseRef.child('Comments').child(commentId).get(),
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.hasData && commentSnapshot.data != null) {
                                  Map<dynamic, dynamic> commentData = commentSnapshot.data!.value as Map<dynamic, dynamic>;
                                  double rating = (commentData['rating'] as num).toDouble();
                                  String comment = commentData['comment'] as String? ?? '';
                                  String userId = commentData['userId'] as String? ?? '';
                                  int timestamp = commentData['timestamp'] ?? 0;
                                  String formattedDate = formatTimestamp(timestamp);

                                  return FutureBuilder<DataSnapshot>(
                                    future: _databaseRef.child('users').child(userId).get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasData && userSnapshot.data != null) {
                                        Map<dynamic, dynamic> userData = userSnapshot.data!.value as Map<dynamic, dynamic>;
                                        String username = userData['name'] as String? ?? 'Anonymous';
                                        String? userImageUrl = userData['imageUrl'] as String?;

                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: userImageUrl != null && userImageUrl.isNotEmpty
                                                  ? CircleAvatar(
                                                      backgroundImage: NetworkImage(userImageUrl),
                                                    )
                                                  : CircleAvatar(
                                                      child: Icon(Icons.person),
                                                    ),
                                              title: Text(username, style: TextStyle(color: Colors.black)),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      RatingBarIndicator(
                                                        rating: rating,
                                                        itemBuilder: (context, index) => Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        itemCount: 5,
                                                        itemSize: 20.0,
                                                        direction: Axis.horizontal,
                                                      ),
                                                      Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.black)),
                                                    ],
                                                  ),
                                                  Text(comment, style: TextStyle(color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                            Divider(color: Colors.grey),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                child: Icon(Icons.person),
                                              ),
                                              title: Text('Loading...', style: TextStyle(color: Colors.black)),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      RatingBarIndicator(
                                                        rating: rating,
                                                        itemBuilder: (context, index) => Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        itemCount: 5,
                                                        itemSize: 20.0,
                                                        direction: Axis.horizontal,
                                                      ),
                                                      Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.black)),
                                                    ],
                                                  ),
                                                  Text(comment, style: TextStyle(color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                            Divider(color: Colors.grey),
                                          ],
                                        );
                                      }
                                    },
                                  );
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return Center(child: Text('No ratings and comments found', style: TextStyle(color: Colors.black)));
                      }
                    } else {
                      return Center(child: Text('No ratings and comments found', style: TextStyle(color: Colors.black)));
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF76CE),
                        Color(
                          0xFFA3D8FF),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ElevatedButton(
                    onPressed: _navigateToAddCommentPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(
                      'Add Comment',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
