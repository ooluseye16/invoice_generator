import 'package:flutter/material.dart';
import 'package:invoice_generator/screens/home/create_organization.dart';
import 'package:invoice_generator/screens/organization_screen.dart';
import 'package:invoice_generator/screens/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateroute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case OrganizationScreen.routeName:
        return MaterialPageRoute(
            builder: (context) => const OrganizationScreen());
      case CreateOrganizationScreen.routeName:
        return MaterialPageRoute(
            builder: (context) => const CreateOrganizationScreen());
      default:
        return MaterialPageRoute(
            builder: (context) => const Scaffold(
                  body: Center(child: Text('No route defined')),
                ));
    }
  }
}
