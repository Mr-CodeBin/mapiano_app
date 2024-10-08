import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<LatLng> getCoordinatesFromLocation(String location) async {
    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    // For simplicity, return hardcoded coordinates for now
    // You can integrate a geocoding service like Google's Geocoding API
    // return LatLng(37.7749, -122.4194);

    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        return LatLng(lat, lng);
      } else {
        throw Exception('Failed to get coordinates');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  static Future<LatLng> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }
}
