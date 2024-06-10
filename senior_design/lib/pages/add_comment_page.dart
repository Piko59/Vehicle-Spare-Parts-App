import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddCommentPage extends StatefulWidget {
  final String businessUid;

  AddCommentPage({required this.businessUid});

  @override
  _AddCommentPageState createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  double _rating = 0.0;
  String _comment = '';
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isSubmitting = false;

  void _submitComment() async {
    setState(() {
      _isSubmitting = true;
    });

    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    try {
      DatabaseReference newCommentRef = _databaseRef.child('Comments').push();
      String commentId = newCommentRef.key ?? '';

      await newCommentRef.set({
        'rating': _rating,
        'comment': _comment,
        'userId': currentUserId,
        'businessId': widget.businessUid,
        'timestamp': timestamp,
      });

      await _databaseRef
          .child('users')
          .child(widget.businessUid)
          .child('receivedComments')
          .child(commentId)
          .set(true);

      await _databaseRef
          .child('users')
          .child(currentUserId)
          .child('givenComments')
          .child(commentId)
          .set(true);

      DatabaseReference userRef =
          _databaseRef.child('users').child(widget.businessUid);
      DataSnapshot snapshot =
          await userRef.child('receivedComments').get();
      double totalRating = 0.0;
      int ratingCount = 0;

      if (snapshot.exists) {
        Map<dynamic, dynamic> commentIds = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in commentIds.entries) {
          DataSnapshot commentSnapshot =
              await _databaseRef.child('Comments').child(entry.key).get();
          if (commentSnapshot.exists) {
            Map<dynamic, dynamic> commentData =
                commentSnapshot.value as Map<dynamic, dynamic>;
            totalRating += commentData['rating'];
            ratingCount += 1;
          }
        }
      }

      double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

      await userRef.update({'averageRating': averageRating});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment added successfully!'),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment: $error'),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          'Add Comment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
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
                  onPressed: _isSubmitting ? null : _submitComment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _isSubmitting
                          ? null
                          : LinearGradient(
                              colors: [Color(0xFFFF76CE), Color(0xFFA3D8FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 50,
                        minHeight: 50,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
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
