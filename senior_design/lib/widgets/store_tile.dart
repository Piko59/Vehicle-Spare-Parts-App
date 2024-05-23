import 'package:flutter/material.dart';

class StoreTile extends StatelessWidget {
  final String name;
  final String distance;
  final String imageUrl;
  final double rating;
  final int reviews;

  const StoreTile({Key? key, required this.name, required this.distance, required this.imageUrl, required this.rating, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(imageUrl, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.blue, size: 20),
              SizedBox(width: 4),
              Text('$rating($reviews)', style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 4),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(distance),
        ],
      ),
    );
  }
}
