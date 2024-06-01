import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'comments_page.dart'; // Import the CommentsPage here

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
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAverageRating();
  }

  void _fetchAverageRating() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    DatabaseEvent event = await databaseReference
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
        setState(() {
          _averageRating = totalRatings / ratingsCount;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Details',
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: widget.businessImageUrl != null && widget.businessImageUrl!.isNotEmpty
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
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(8),
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
              SizedBox(height: 16),
              Text(
                widget.businessName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.businessCategory,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Phone: ${widget.businessPhoneNumber}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(businessUid: widget.businessUid),
                      ),
                    );
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
                  child: Text('View and Add Comments'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
