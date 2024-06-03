import 'package:flutter/material.dart';
import 'package:senior_design/pages/category_detail_page.dart';

class BicycleCategoriesPage extends StatelessWidget {
  final List<String> bicycleCategories = [
    'Handlebar', 'Brake', 'Rotor', 'Bearing', 'Rim', 'Frame', 'Drivetrain Components',
    'Electric Components', 'Cockpit', 'Brake Pad',
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
            'Bicycle Categories',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      body: ListView.builder(
        itemCount: bicycleCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            bicycleCategories[index],
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(category: 'Bicycle', partCategory: bicycleCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
