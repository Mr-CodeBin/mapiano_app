import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class TempService {
  Future<double> getTemp(String lat, String longi) {
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$longi&current=temperature_2m,wind_speed_10m';
    // 'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m,wind_speed_10m';

    return http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        // log(response.body);
        final data = json.decode(response.body);

        double temp = data['current']['temperature_2m'];
        // log(temp.toString());
        return temp;
      } else {
        throw Exception('Failed to fetch data from API');
      }
    });
  }
}
