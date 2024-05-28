import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessUid;
  final String businessName;
  final String? businessImageUrl;
  final String businessCategory;
  final String businessPhoneNumber;

  BusinessDetailsPage({
    required this.businessUid,
    required this.businessName,
    required this.businessImageUrl,
    required this.businessCategory,
    required this.businessPhoneNumber,
  });

  @override
  _BusinessDetailsPageState createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  double _rating = 0.0;
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.businessImageUrl != null &&
                    widget.businessImageUrl!.isNotEmpty
                ? Image.network(
                    widget.businessImageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child: Icon(Icons.business, size: 100),
                  ),
            SizedBox(height: 16),
            Text(
              widget.businessName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.businessCategory,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: ${widget.businessPhoneNumber}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
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
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

                DatabaseReference reference =
                    FirebaseDatabase.instance.reference();

                // Veri eklenirken ayrım yapılması için yeni bir anahtar oluşturulur
                String newKey = reference
                        .child('users')
                        .child(userId)
                        .child('givenRatingsAndComments')
                        .push()
                        .key ??
                    '';

                // Rating ve yorumlar kullanıcının kendi veri yapısına eklenir
                reference
                    .child('users')
                    .child(userId)
                    .child('givenRatingsAndComments')
                    .child(newKey)
                    .set({
                  'businessUid': widget.businessUid,
                  'rating': _rating,
                  'comment': _comment,
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rating and comment added successfully!'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add rating and comment: $error'),
                    ),
                  );
                });

                // Rating ve yorumlar işletme sahibinin veri yapısına eklenir
                reference
                    .child('users')
                    .child(widget.businessUid)
                    .child('receivedRatingsAndComments')
                    .child(userId)
                    .set({
                  'rating': _rating,
                  'comment': _comment,
                });
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
