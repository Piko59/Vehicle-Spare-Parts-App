import 'package:flutter/material.dart';
import 'package:senior_design/pages/category_detail_page.dart';

class CarCategoriesPage extends StatelessWidget {
  final List<String> carCategories = [
    'Ateşleme & Yakıt', 'Egzoz', 'Elektrik', 'Filtre', 'Fren & Debriyaj', 'Isıtma & Havalandırma & Klima',
    'Mekanik', 'Motor', 'Şanzıman & Vites', 'Yürüyen & Direksiyon',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Araba Kategorileri'),
      ),
      body: ListView.builder(
        itemCount: carCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(carCategories[index]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(category: 'Araba', partCategory: carCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
