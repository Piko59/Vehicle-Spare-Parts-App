import 'package:flutter/material.dart';
import 'package:senior_design/pages/category_detail_page.dart';

class CarCategoriesPage extends StatelessWidget {
  final List<String> carCategories = [
    'Ignition & Fuel', 'Exhaust', 'Electrical', 'Filter', 'Brake & Clutch', 'Heating & Ventilation & Air Conditioning',
    'Mechanical', 'Engine', 'Transmission & Gear', 'Suspension & Steering',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00A9B7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Car Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: carCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            carCategories[index],
            style: TextStyle(
              fontSize: 18.0, 
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(category: 'Car', partCategory: carCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
