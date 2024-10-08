import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapiano_app/services/location_services.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _locationCoordinates;
  LatLng? _myCurrentLocation;
  late MapController _mapController;
  String _selectedTerrain = 'streets';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mapController = MapController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location =
        ModalRoute.of(context)!.settings.arguments as String;
    _getLocationCoordinates(location);
  }

  void _getLocationCoordinates(String location) async {
    final LatLng coordinates =
        await LocationService.getCoordinatesFromLocation(location);
    setState(() {
      _locationCoordinates = coordinates;
    });
  }

  Future<bool> _getLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocationFromRequest() async {
    final bool permissionGranted = await _getLocationPermission(context);
    if (!permissionGranted) {
      return;
    }
    try {
      final LatLng coordinates = await LocationService.getCurrentLocation();
      log('Current location: $coordinates');
      setState(() {
        _myCurrentLocation = coordinates;
      });
      _mapController.move(coordinates, 13.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred while fetching the location')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _getCurrentLocationFromRequest();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fetching current location')));
            },
          ),
        ],
      ),
      body: _locationCoordinates == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: _locationCoordinates!,
                initialZoom: 13.0,
              ),
              mapController: _mapController,
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  additionalOptions: const {
                    'id': 'mapbox.streets',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _locationCoordinates!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    if (_myCurrentLocation != null)
                      Marker(
                        point: _myCurrentLocation!,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.grey[100],
                      value: _selectedTerrain,
                      items: const [
                        DropdownMenuItem(
                          value: 'streets',
                          child: Text('Streets'),
                        ),
                        DropdownMenuItem(
                          value: 'satellite',
                          child: Text('Satellite'),
                        ),
                        DropdownMenuItem(
                          value: 'terrain',
                          child: Text('Terrain'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTerrain = value!;
                        });
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _mapController.move(_locationCoordinates!, 13.0);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
