import 'package:flutter/material.dart';

class PartDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  final String brand;
  final bool isNew;
  final int year;

  PartDetailScreen({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.brand,
    required this.isNew,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part Detayları'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Image.network(
              imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price:'),
                Text(price.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Brand:'),
                Text(brand),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Is New:'),
                Text(isNew.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Year:'),
                Text(year.toString()),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Mesaj gönderme işlemi
              },
              child: Text('Mesaj Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
