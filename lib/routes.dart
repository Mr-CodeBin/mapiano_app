import 'package:flutter/material.dart';
import 'package:mapiano_app/screens/home_page.dart';
import 'package:mapiano_app/screens/map_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }
      // '/mapScreen': (context) => MapPage(),
      case '/mapScreen':
        {
          String location = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => MapPage(
              location: location,
            ),
          );
        }
      default:
        {
          return _errorRoute();
        }
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        body: Center(
          child: Text(
            'Page does not exist',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
    });
  }
}
