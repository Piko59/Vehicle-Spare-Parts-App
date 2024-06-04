import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class OtherUserCommentsPage extends StatefulWidget {
  final String userId;

  OtherUserCommentsPage({required this.userId});

  @override
  _OtherUserCommentsPageState createState() => _OtherUserCommentsPageState();
}

class _OtherUserCommentsPageState extends State<OtherUserCommentsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadUserComments();
  }

  Future<void> _loadUserComments() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('users/${widget.userId}/receivedRatingsAndComments').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> commentsMap = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> commentsList = commentsMap.entries.map((entry) {
          return {
            'id': entry.key,
            'rating': entry.value['rating'] ?? 0,
            'comment': entry.value['comment'] ?? '',
            'userId': entry.value['userId'] ?? '',
            'timestamp': entry.value['timestamp'] ?? 0,
          };
        }).toList();

        setState(() {
          _comments = commentsList;
        });
      }
    } catch (e) {
      print('Error loading user comments: $e');
    }
  }

  String formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy HH:mm').format(date);
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
          title: Text('User Comments',
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
                  future: _databaseRef.child('users').child(widget.userId).child('receivedRatingsAndComments').get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot dataSnapshot = snapshot.data!;
                      if (dataSnapshot.value != null) {
                        Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;
                        List<dynamic> itemKeys = data.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return ListView.builder(
                          itemCount: itemKeys.length,
                          itemBuilder: (context, index) {
                            String key = itemKeys[index];
                            double rating = (data[key]['rating'] as num).toDouble();
                            String comment = data[key]['comment'] as String? ?? '';
                            String userId = data[key]['userId'] as String? ?? '';
                            int timestamp = data[key]['timestamp'] ?? 0;
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                            String formattedDate = formatTimestamp(timestamp);

                            return FutureBuilder<DataSnapshot>(
                              future: _databaseRef.child('users').child(userId).get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData && userSnapshot.data != null) {
                                  Map<dynamic, dynamic> userData = userSnapshot.data!.value as Map<dynamic, dynamic>;
                                  String username = userData['username'] as String? ?? 'Anonymous';
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
