import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CommentsPage extends StatefulWidget {
  final String businessUid;

  CommentsPage({required this.businessUid});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  double _rating = 0.0;
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFCCCCFF),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCCCCFF), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Rate your experience',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _comment = value;
                  });
                },
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your comment...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addRatingAndComment();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Send'),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .reference()
                      .child('users')
                      .child(widget.businessUid)
                      .child('receivedRatingsAndComments')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot dataSnapshot = snapshot.data!.snapshot;
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
                            int timestamp = int.parse(key);
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                            String formattedDate = DateFormat('dd MMM yyyy HH:mm').format(date);

                            return FutureBuilder<DataSnapshot>(
                              future: FirebaseDatabase.instance
                                  .reference()
                                  .child('users')
                                  .child(userId)
                                  .get(),
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

  void _addRatingAndComment() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String commentId = '$timestamp';

    DatabaseReference reference =
        FirebaseDatabase.instance.reference();

    reference
        .child('users')
        .child(widget.businessUid)
        .child('receivedRatingsAndComments')
        .child(commentId)
        .set({
      'rating': _rating,
      'comment': _comment,
      'userId': userId,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating and comment added successfully!'),
        ),
      );
      _updateAverageRating();
      Navigator.pop(context, true);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add rating and comment: $error'),
        ),
      );
    });
  }

  void _updateAverageRating() async {
    DatabaseReference reference = FirebaseDatabase.instance.reference();
    DatabaseEvent event = await reference
        .child('users')
        .child(widget.businessUid)
        .child('receivedRatingsAndComments')
        .once();

    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;
      double totalRatings = 0.0;
      int ratingsCount = 0;

      values.forEach((key, value) {
        if (value['rating'] != null) {
          totalRatings += (value['rating'] as num).toDouble();
          ratingsCount++;
        }
      });

      if (ratingsCount > 0) {
        double averageRating = totalRatings / ratingsCount;
        await reference.child('users').child(widget.businessUid).child('averageRating').set(averageRating);
      }
    }
  }
}
