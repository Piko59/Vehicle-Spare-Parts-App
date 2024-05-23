import 'package:flutter/material.dart';
import 'store_tile.dart';

class PopularStores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Popular Stores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              StoreTile(
                name: 'Kaportacı Emre Usta',
                distance: '1.7 km',
                imageUrl: 'assets/kaportaci1.jpg',
                rating: 4.5,
                reviews: 744
              ),
              StoreTile(
                name: 'Semizler Kardeş Servis',
                distance: '1.9 km',
                imageUrl: 'assets/kaportaci2.jpg',
                rating: 4.5,
                reviews: 744
              ),
              // Daha fazla StoreTile widget'ı eklenebilir
            ],
          ),
        ),
      ],
    );
  }
}
