import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'part_detail_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialVehicleType;
  final String? initialCategory;

  SearchPage({this.initialVehicleType, this.initialCategory});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();
  FocusNode _minPriceFocusNode = FocusNode();
  FocusNode _maxPriceFocusNode = FocusNode();

  String? _selectedVehicleType;
  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedSortOption;

  final List<String> vehicleTypes = ['Car', 'Motorcycle', 'Bicycle'];
  final Map<String, List<String>> vehicleCategories = {
    'Car': [
      'Ignition & Fuel',
      'Exhaust',
      'Electric',
      'Filter',
      'Brake & Clutch',
      'Mechanical',
      'Engine',
      'Transmission & Gear',
      'Steering & Suspension',
    ],
    'Motorcycle': [
      'Clutch',
      'Exhaust',
      'Electric',
      'Brake',
      'Fairing',
      'Ventilation',
      'Engine',
      'Suspension',
      'Transmission',
      'Lubrication',
      'Fuel System',
      'Steering',
    ],
    'Bicycle': [
      'Handlebar',
      'Brake',
      'Rotor',
      'Bearing',
      'Rim',
      'Frame',
      'Drivetrain Components',
      'Electric Components',
      'Cockpit',
      'Brake Pad',
    ],
  };

  final Map<String, List<String>> vehicleBrands = {
    'Car': [
      'Toyota',
      'Honda',
      'Ford',
      'BMW',
      'Mercedes',
    ],
    'Motorcycle': [
      'Yamaha',
      'Honda',
      'Suzuki',
      'Kawasaki',
      'Ducati',
    ],
    'Bicycle': [
      'Giant',
      'Trek',
      'Specialized',
      'Cannondale',
      'Bianchi',
    ],
  };

  final List<String> sortOptions = [
    'No order',
    'Order by price ascending',
    'Order by price descending',
    'Order by year ascending',
    'Order by year descending'
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = widget.initialVehicleType;
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minPriceFocusNode.dispose();
    _maxPriceFocusNode.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getFilteredParts() {
    Query query = FirebaseFirestore.instance.collection('parts');

    if (_selectedVehicleType != null) {
      query = query.where('vehicle_type', isEqualTo: _selectedVehicleType);
    }

    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    if (_selectedBrand != null) {
      query = query.where('brand', isEqualTo: _selectedBrand);
    }

    if (_minPriceController.text.isNotEmpty) {
      double minPrice = double.tryParse(_minPriceController.text) ?? 0.0;
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (_maxPriceController.text.isNotEmpty) {
      double maxPrice = double.tryParse(_maxPriceController.text) ?? double.infinity;
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    if (_selectedSortOption != null) {
      switch (_selectedSortOption) {
        case 'Order by price ascending':
          query = query.orderBy('price', descending: false);
          break;
        case 'Order by price descending':
          query = query.orderBy('price', descending: true);
          break;
        case 'Order by year ascending':
          query = query.orderBy('year', descending: false);
          break;
        case 'Order by year descending':
          query = query.orderBy('year', descending: true);
          break;
      }
    }

    return query.snapshots();
  }

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    setState(() {
      // Filtering işlemi burada yapılır.
    });
  }

  void _resetFilters() {
    FocusScope.of(context).unfocus();
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedVehicleType = null;
      _selectedCategory = null;
      _selectedBrand = null;
      _selectedSortOption = null;
    });
  }

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
          title: Text('Search Page',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<String>(
                          value: _selectedVehicleType,
                          decoration: InputDecoration(
                            labelText: 'Vehicle Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFA3D8FF), width: 2),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVehicleType = newValue;
                              _selectedCategory = null;
                              _selectedBrand = null;
                            });
                          },
                          items: vehicleTypes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (_selectedVehicleType != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Color(0xFFA3D8FF), width: 2),
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            items: vehicleCategories[_selectedVehicleType]!.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    if (_selectedVehicleType != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<String>(
                            value: _selectedBrand,
                            decoration: InputDecoration(
                              labelText: 'Brand',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Color(0xFFA3D8FF), width: 2),
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedBrand = newValue;
                              });
                            },
                            items: vehicleBrands[_selectedVehicleType]!.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(_minPriceFocusNode);
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _minPriceController,
                              focusNode: _minPriceFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Min Price',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFFA3D8FF), width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                              onSubmitted: (value) {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(_maxPriceFocusNode);
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _maxPriceController,
                              focusNode: _maxPriceFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Max Price',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFFA3D8FF), width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus(); // Klavyeyi kapat
                              },
                              onSubmitted: (value) {
                                FocusScope.of(context).unfocus(); // Klavyeyi kapat
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSortOption,
                          decoration: InputDecoration(
                            labelText: 'Sort by',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFA3D8FF), width: 2),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSortOption = newValue;
                            });
                          },
                          items: sortOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 100,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFA3D8FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          child: Text(
                            'Filter',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 140,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _resetFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF76CE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          child: Text(
                            'Reset Filters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredParts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final parts = snapshot.data!.docs;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: parts.length,
                      itemBuilder: (context, index) {
                        final part = parts[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PartDetailPage(
                                  title: part['title'],
                                  imageUrls: List<String>.from(part['image_urls']),
                                  description: part['description'],
                                  price: part['price'],
                                  brand: part['brand'],
                                  isNew: part['isNew'],
                                  year: part['year'],
                                  userId: part['user_id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                      child: Image.network(
                                        part['image_urls'][0], // İlk fotoğrafı kullan
                                        fit: BoxFit.cover,
                                        height: MediaQuery.of(context).size.width / 2,
                                        width: MediaQuery.of(context).size.width / 2,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        part['title'],
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(), // Boş alan bırakmak için kullanılır
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          "\$${part['price'].toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
