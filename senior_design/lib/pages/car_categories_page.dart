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
        backgroundColor: Color(0xFF00A9B7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Araba Kategorileri',
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
              fontSize: 18.0, // Yazı tipi boyutunu artırdık
              fontWeight: FontWeight.bold, // Yazı tipi kalın
            ),
          ),
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
