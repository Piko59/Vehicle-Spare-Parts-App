import 'package:flutter/material.dart';
import 'package:senior_design/pages/car_categories_page.dart';
import 'package:senior_design/pages/motorcycle_categories_page.dart';
import 'package:senior_design/pages/bicycle_categories_page.dart';

class VehiclePartIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.directions_car, size: 40),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CarCategoriesPage()));
          },
        ),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.directions_bike, size: 40),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BicycleCategoriesPage()));
          },
        ),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.motorcycle, size: 40),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MotorcycleCategoriesPage()));
          },
        ),
      ],
    );
  }
}