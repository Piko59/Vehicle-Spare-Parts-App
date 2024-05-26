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
        backgroundColor: Color(0xFF00A9B7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Motorsiklet Kategorileri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
              builder: (context) => CategoryDetailPage(category: 'Motorsiklet', partCategory: motorcycleCategories[index]),
            ),
          ),
        ),
      ),
    );
  }
}
