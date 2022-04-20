import 'package:entalpitrainer/views/bt_connect/bt_connect_view.dart';
import 'package:entalpitrainer/views/simple_workout/simple_workout_view.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // use if passing arguments in nav: final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const BTConnectView(),
        );
      case '/workout':
        return MaterialPageRoute(
          builder: (_) => const SimpleWorkoutView(),
        );
      // If args is not of the correct type, return an error page.
      // You can also throw an exception while in development.
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error: The page does not exist'),
        ),
        body: const Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
