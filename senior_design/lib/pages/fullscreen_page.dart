import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'business_details_page.dart';

class FullscreenPage extends StatefulWidget {
  @override
  _FullscreenPageState createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final List<Map<String, dynamic>> _businesses = [];
  final Map<String, dynamic> _visibleBusinesses = {};

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _fetchBusinessLocations();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied) {
      print('Location permission denied');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 14.4746),
        ));
      }
    });
  }

  Future<void> _fetchBusinessLocations() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('users');
    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
    Map<dynamic, dynamic>? users = snapshot.value as Map<dynamic, dynamic>?;

    if (users != null) {
      users.forEach((key, value) {
        if (value['businessCategory'] != null && value['location'] != null) {
          var location = value['location'];
          LatLng position = LatLng(location['latitude'], location['longitude']);
          Marker marker = Marker(
            markerId: MarkerId(key),
            position: position,
            infoWindow: InfoWindow(
              title: value['name'] ?? 'No Name',
              snippet: value['businessCategory'] ?? 'No Category',
            ),
            onTap: () {
              _navigateToBusinessDetail(key);
            },
          );
          setState(() {
            _markers.add(marker);
            _businesses.add({
              'key': key,
              'name': value['name'] ?? 'No Name',
              'imageUrl': value['imageUrl'],
              'businessCategory': value['businessCategory'] ?? 'No Category',
              'position': position,
            });
          });
        }
      });
    }
  }

  void _navigateToBusinessDetail(String key) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailsPage(
          businessUid: key,
        ),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    Set<String> newVisibleBusinesses = {};
    _markers.forEach((marker) {
      if (_isMarkerVisible(marker, position.target)) {
        newVisibleBusinesses.add(marker.markerId.value);
      }
    });
    setState(() {
      _visibleBusinesses.clear();
      newVisibleBusinesses.forEach((key) {
        _visibleBusinesses[key] =
            _businesses.firstWhere((b) => b['key'] == key);
      });
    });
  }

  bool _isMarkerVisible(Marker marker, LatLng target) {
    const double visibleDistance = 0.01;
    return (marker.position.latitude - target.latitude).abs() <=
            visibleDistance &&
        (marker.position.longitude - target.longitude).abs() <= visibleDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
        backgroundColor: Color(0xFFCCCCFF),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14.4746,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onCameraMove: _onCameraMove,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _visibleBusinesses.values.map((business) {
                        return GestureDetector(
                          onTap: () {
                            _navigateToBusinessDetail(business['key']);
                          },
                          child: Card(
                            margin: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                business['imageUrl'] != null
                                    ? Image.network(
                                        business['imageUrl'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child: Icon(Icons.business, size: 50),
                                      ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    business['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    business['businessCategory'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
