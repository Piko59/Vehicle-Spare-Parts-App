import 'package:flutter/material.dart';
import 'package:senior_design/pages/category_detail_page.dart';

class BicycleCategoriesPage extends StatelessWidget {
  final List<String> bicycleCategories = [
    'Gidon', 'Fren', 'Rotor', 'Bilya', 'Jant', 'Kadro', 'Çekiş Parçaları',
    'Elektrik Parçaları', 'Kokpit', 'Pabuç',
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
          'Bisiklet Kategorileri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: bicycleCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            bicycleCategories[index],
            style: TextStyle(
              fontSize: 18.0, // Yazı tipi boyutunu artırdık
              fontWeight: FontWeight.bold, // Yazı tipi kalın
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(category: 'Bisiklet', partCategory: bicycleCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
