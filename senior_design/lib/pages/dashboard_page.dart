import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarCategoriesPage()),
                );
              },
              child: Text('Araba'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MotorcycleCategoriesPage()),
                );
              },
              child: Text('Motorsiklet'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BicycleCategoriesPage()),
                );
              },
              child: Text('Bisiklet'),
            ),
          ],
        ),
      ),
    );
  }
}

class CarCategoriesPage extends StatelessWidget {
  final List<String> carCategories = [
    'Ateşleme & Yakıt',
    'Egzoz',
    'Elektrik',
    'Filtre',
    'Fren & Debriyaj',
    'Isıtma & Havalandırma & Klima',
    'Mekanik',
    'Motor',
    'Şanzıman & Vites',
    'Yürüyen & Direksiyon',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Araba Kategorileri'),
      ),
      body: ListView.builder(
        itemCount: carCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(carCategories[index]),
            onTap: () {
              // Kategoriye tıklanınca ne olacağını burada belirleyin
            },
          );
        },
      ),
    );
  }
}

class MotorcycleCategoriesPage extends StatelessWidget {
  final List<String> motorcycleCategories = [
    'Debriyaj',
    'Egzoz',
    'Elektrik',
    'Fren',
    'Grenaj',
    'Havalandırma',
    'Motor',
    'Süspansiyon',
    'Şanzıman',
    'Yağlama',
    'Yakıt Sistemi',
    'Yönlendirme',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motorsiklet Kategorileri'),
      ),
      body: ListView.builder(
        itemCount: motorcycleCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(motorcycleCategories[index]),
            onTap: () {
              // Kategoriye tıklanınca ne olacağını burada belirleyin
            },
          );
        },
      ),
    );
  }
}

class BicycleCategoriesPage extends StatelessWidget {
  final List<String> bicycleCategories = [
    'Gidon',
    'Fren',
    'Rotor',
    'Bilya',
    'Jant',
    'Kadro',
    'Çekiş Parçaları',
    'Elektrik Parçaları',
    'Kokpit',
    'Pabuç',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bisiklet Kategorileri'),
      ),
      body: ListView.builder(
        itemCount: bicycleCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bicycleCategories[index]),
            onTap: () {
              // Kategoriye tıklanınca ne olacağını burada belirleyin
            },
          );
        },
      ),
    );
  }
}
