import 'package:flutter/material.dart';
import 'package:senior_design/pages/category_detail_page.dart';

class MotorcycleCategoriesPage extends StatelessWidget {
  final List<String> motorcycleCategories = [
    'Clutch', 'Exhaust', 'Electrical', 'Brake', 'Fairing', 'Ventilation', 'Engine',
    'Suspension', 'Transmission', 'Lubrication', 'Fuel System', 'Steering',
  ];

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Motorcycle Categories',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      body: ListView.builder(
        itemCount: motorcycleCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            motorcycleCategories[index],
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(category: 'Motorcycle', partCategory: motorcycleCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
