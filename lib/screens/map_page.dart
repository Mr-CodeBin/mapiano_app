import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapiano_app/services/location_services.dart';
import 'package:mapiano_app/services/temp_service.dart';

class MapPage extends StatefulWidget {
  final String location;
  const MapPage({
    super.key,
    required this.location,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _locationCoordinates;
  LatLng? _myCurrentLocation;
  late MapController _mapController;
  String _selectedTerrain = 'streets';
  double _temp = 0.0;
  late String placeName = '...';
  bool isPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mapController = MapController();
    _getLocationCoordinates(widget.location).then(
      (value) {
        getTemp();
      },
    );
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> _getLocationCoordinates(String location) async {
    final result = await LocationService.getCoordinatesFromLocation(location);
    log(result.toString(), name: 'Location Coordinates');
    setState(() {
      _locationCoordinates = result['coordinates'];
      placeName = result['placeName'].toString();
    });
  }

  Future<void> getTemp() async {
    log('Getting temp');
    final double temp = await TempService().getTemp(
        _locationCoordinates!.latitude.toString(),
        _locationCoordinates!.longitude.toString());
    setState(() {
      isPressed = true;
      _temp = temp;
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
      // log('Current location: $coordinates');
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
          title: Text(
            placeName,
            style: GoogleFonts.inter(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
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
        body: Column(
          children: [
            TempBarWidget(),
            const Spacer(),
            _locationCoordinates == null
                ? const CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.5 ?? 0,
                      width: MediaQuery.of(context).size.width - 20,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _locationCoordinates!,
                          initialZoom: 13.0,
                        ),
                        mapController: _mapController,
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            fallbackUrl:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            additionalOptions: const {
                              'id': 'mapbox.streets',
                            },
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                height: 100,
                                width: 100,
                                rotate: true,
                                point: _locationCoordinates!,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    (isPressed)
                                        ? Chip(
                                            label: Text(
                                              '$_temp°C',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Colors.white,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                            backgroundColor:
                                                const Color(0xff7201A8),
                                          )
                                        : Container(),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ],
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: DropdownButton<String>(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                  _mapController.move(
                                      _locationCoordinates!, 13.0);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const Spacer(),
          ],
        ));
  }

  TempBarWidget() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            0,
            12,
            12,
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xff7201A8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              Text(
                '$_temp°C',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              const Color(0xff7201A8),
            ),
          ),
          onPressed: () {
            getTemp();
          },
          child: Text(
            'Show Temp',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        )
      ],
    );
  }
}
