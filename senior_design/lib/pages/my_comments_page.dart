import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'edit_comment_page.dart';

class MyCommentsPage extends StatefulWidget {
  @override
  _MyCommentsPageState createState() => _MyCommentsPageState();
}

class _MyCommentsPageState extends State<MyCommentsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy HH:mm').format(date);
  }

  Future<void> _deleteComment(String commentId, String businessId) async {
    try {
      await _databaseRef.child('Comments').child(commentId).remove();
      await _databaseRef.child('users').child(_currentUser!.uid).child('givenComments').child(commentId).remove();
      await _databaseRef.child('users').child(businessId).child('receivedComments').child(commentId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment deleted successfully')),
      );
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $error')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(String commentId, String businessId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Comment', style: TextStyle(color: Colors.red)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this comment?', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComment(commentId, businessId);
              },
            ),
          ],
        );
      },
    );
  }

  void _editComment(String commentId, String businessId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCommentPage(commentId: commentId, businessId: businessId)),
    );
    setState(() {});
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
          title: Text('My Comments',
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
                child: StreamBuilder(
                  stream: _databaseRef
                      .child('users')
                      .child(_currentUser?.uid ?? '')
                      .child('givenComments')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot dataSnapshot = snapshot.data!.snapshot;
                      if (dataSnapshot.value != null) {
                        Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;
                        List<dynamic> commentIds = data.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return ListView.builder(
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
                                  String businessId = commentData['businessId'] as String? ?? '';
                                  int timestamp = commentData['timestamp'] ?? 0;
                                  String formattedDate = formatTimestamp(timestamp);

                                  return FutureBuilder<DataSnapshot>(
                                    future: _databaseRef.child('users').child(businessId).get(),
                                    builder: (context, businessSnapshot) {
                                      if (businessSnapshot.hasData && businessSnapshot.data != null) {
                                        Map<dynamic, dynamic> businessData = businessSnapshot.data!.value as Map<dynamic, dynamic>;
                                        String businessName = businessData['name'] as String? ?? 'Unknown';
                                        String? businessImageUrl = businessData['imageUrl'] as String?;

                                        return Column(
                                          children: [
                                            Stack(
                                              children: [
                                                ListTile(
                                                  leading: businessImageUrl != null && businessImageUrl.isNotEmpty
                                                      ? CircleAvatar(
                                                          backgroundImage: NetworkImage(businessImageUrl),
                                                        )
                                                      : CircleAvatar(
                                                          child: Icon(Icons.business),
                                                        ),
                                                  title: Text(businessName, style: TextStyle(color: Colors.black)),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      Text(comment, style: TextStyle(color: Colors.black)),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit, color: Colors.blue),
                                                        onPressed: () => _editComment(commentId, businessId),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => _showDeleteConfirmationDialog(commentId, businessId),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 16,
                                                  bottom: 0,
                                                  child: Text(
                                                    formattedDate,
                                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                child: Icon(Icons.business),
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
            ],
          ),
        ),
      ),
    );
  }
}
