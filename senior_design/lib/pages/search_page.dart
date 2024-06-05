import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();

  String? _selectedVehicleType;
  String? _selectedCategory;
  String? _selectedBrand;

  final List<String> vehicleTypes = ['Car', 'Motorcycle', 'Bicycle'];
  final Map<String, List<String>> vehicleCategories = {
    'Car': [
      'Ignition & Fuel',
      'Exhaust',
      'Electric',
      'Filter',
      'Brake & Clutch',
      'Heating & Ventilation & Air Conditioning',
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

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
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

    return query.snapshots();
  }

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    setState(() {
      // Destroying the keyboard is enough for the filtering process to occur.
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
                        child: TextField(
                          controller: _minPriceController,
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
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        child: TextField(
                          controller: _maxPriceController,
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
                    return ListView.builder(
                      itemCount: parts.length,
                      itemBuilder: (context, index) {
                        final part = parts[index];
                        return ListTile(
                          title: Text(part['title']),
                          subtitle: Text(part['description']),
                          leading: Image.network(part['image_url'], width: 50, height: 50),
                          trailing: Text("\$${part['price'].toStringAsFixed(2)}"),
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
