import 'package:flutter/material.dart';
import 'package:invoice_generator/components/routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(OrganizationAdapter());
  Hive.registerAdapter(InvoiceFormFieldAdapter());
  Hive.registerAdapter(FormFieldTypeAdapter());
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: RouteGenerator.generateroute,
      initialRoute: SplashScreen.routeName,
    );
  }
}
