// app_route.dart
import 'package:demo_application/features/call/calling_page.dart';
import 'package:demo_application/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';

class AppRoute {
  static const homePage = '/home_page';
  static const callingPage = '/calling_page';

  static Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case callingPage:
        final args = settings.arguments;
        if (args is CallKitParams) {
          return MaterialPageRoute(
            builder: (_) => CallingPage(callKitParams: args),
            settings: settings,
          );
        }
        return _errorRoute("Invalid arguments for CallingPage");
      default:
        return _errorRoute("Route not found: ${settings.name}");
    }
  }

  static Route<Object> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }
}
