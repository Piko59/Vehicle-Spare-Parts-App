// Araba Markaları
enum CarBrand {
  Honda,
  Mercedes,
  Porsche,
  RollsRoyce,
  Toyota,
  Volkswagen,
}

// Motorsiklet Markaları
enum MotorcycleBrand {
  Kawasaki,
  HarleyDavidson,
  Ducati,
  VespaScooter,
  BMW,
}

// Bisiklet Markaları
enum BicycleBrand {
  Scott,
  Ghost,
  Lapierre,
  Carraro,
  Salcano,
  Kron,
  Bianchi,
}

// Parça kategorileri
enum CarPartCategory {
  AteslemeYakit,
  Egzoz,
  Elektrik,
  Filtre,
  FrenDebriyaj,
  IsitmaHavalandirmaKlima,
  Mekanik,
  Motor,
  SanzimanVites,
  YuruyenDireksiyon,
}

enum MotorcyclePartCategory {
  Debriyaj,
  Egzoz,
  Elektrik,
  Fren,
  Grenaj,
  Havalandirma,
  Motor,
  Suslendirme,
  Sanziman,
  Yaglama,
  YakitSistemi,
  Yonlendirme,
}

enum BicyclePartCategory {
  Gidon,
  Fren,
  Rotor,
  Bilya,
  Jant,
  Kadro,
  CekisParcalari,
  ElektrikParcalari,
  Kokpit,
  Pabuc,
}

// Parça sınıfları
class Part {
  final dynamic vehicleBrand;
  final String image;
  final String title;
  final String brand;
  final int year;
  final bool isNew;
  final double price;
  final String description;
  final List<String> comments;
  final double rating;

  Part({
    required this.vehicleBrand,
    required this.image,
    required this.title,
    required this.brand,
    required this.year,
    required this.isNew,
    required this.price,
    required this.description,
    required this.comments,
    required this.rating,
  });
}

class CarPart extends Part {
  final CarPartCategory partCategory;

  CarPart({
    required CarBrand vehicleBrand,
    required this.partCategory,
    required String image,
    required String title,
    required String brand,
    required int year,
    required bool isNew,
    required double price,
    required String description,
    required List<String> comments,
    required double rating,
  }) : super(
          vehicleBrand: vehicleBrand,
          image: image,
          title: title,
          brand: brand,
          year: year,
          isNew: isNew,
          price: price,
          description: description,
          comments: comments,
          rating: rating,
        );
}

class MotorcyclePart extends Part {
  final MotorcyclePartCategory partCategory;

  MotorcyclePart({
    required MotorcycleBrand vehicleBrand,
    required this.partCategory,
    required String image,
    required String title,
    required String brand,
    required int year,
    required bool isNew,
    required double price,
    required String description,
    required List<String> comments,
    required double rating,
  }) : super(
          vehicleBrand: vehicleBrand,
          image: image,
          title: title,
          brand: brand,
          year: year,
          isNew: isNew,
          price: price,
          description: description,
          comments: comments,
          rating: rating,
        );
}

class BicyclePart extends Part {
  final BicyclePartCategory partCategory;

  BicyclePart({
    required BicycleBrand vehicleBrand,
    required this.partCategory,
    required String image,
    required String title,
    required String brand,
    required int year,
    required bool isNew,
    required double price,
    required String description,
    required List<String> comments,
    required double rating,
  }) : super(
          vehicleBrand: vehicleBrand,
          image: image,
          title: title,
          brand: brand,
          year: year,
          isNew: isNew,
          price: price,
          description: description,
          comments: comments,
          rating: rating,
        );
}
