import 'package:flutter/material.dart';
import 'package:senior_design/pages/category_detail_page.dart';

class MotorcycleCategoriesPage extends StatelessWidget {
  final List<String> motorcycleCategories = [
    'Debriyaj', 'Egzoz', 'Elektrik', 'Fren', 'Grenaj', 'Havalandırma', 'Motor',
    'Süspansiyon', 'Şanzıman', 'Yağlama', 'Yakıt Sistemi', 'Yönlendirme',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motorsiklet Kategorileri'),
      ),
      body: ListView.builder(
        itemCount: motorcycleCategories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(motorcycleCategories[index]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(category: 'Motorsiklet', partCategory: motorcycleCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
