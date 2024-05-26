import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  Location _location = Location();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Color(0xFF00A9B7),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_selectedLocation != null) {
                Navigator.pop(context, _selectedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a location')),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Default to San Francisco
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _location.onLocationChanged.listen((LocationData currentLocation) {
            if (_selectedLocation == null) {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      currentLocation.latitude!,
                      currentLocation.longitude!,
                    ),
                    zoom: 14.0,
                  ),
                ),
              );
            }
          });
        },
        onTap: (LatLng position) {
          setState(() {
            _selectedLocation = position;
          });
        },
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
            },
          ),
        }
            : {},
      ),
    );
  }
}
