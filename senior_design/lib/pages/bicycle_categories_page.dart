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
        title: Text('Bisiklet Kategorileri'),
      ),
      body: ListView.builder(
        itemCount: bicycleCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(bicycleCategories[index]),
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
