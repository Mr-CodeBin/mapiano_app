import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<Map<String, dynamic>> getCoordinatesFromLocation(
      String location) async {
    // For simplicity, return hardcoded coordinates for now
    // return LatLng(37.7749, -122.4194);

    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log(data.toString(), name: "API map");
      if (data['status'] == 'OK') {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        final placeName =
            data['results'][0]['address_components'][0]['short_name'];
        // log('Coordinates: $lat, $lng', name: 'Location Coordinates');
        return {
          'coordinates': LatLng(lat, lng),
          'placeName': placeName,
        };
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
