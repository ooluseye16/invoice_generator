import 'package:flutter/material.dart';
import 'package:invoice_generator/components/routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/data/models/invoice.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  try {
    // Register Adapters
    Hive.registerAdapter(OrganizationAdapter());
    Hive.registerAdapter(InvoiceFormFieldAdapter());
    Hive.registerAdapter(FormFieldTypeAdapter());
    Hive.registerAdapter(InvoiceAdapter());
  } catch (e) {
    // If there's corruption in the Hive boxes, delete and recreate them
    await Hive.deleteBoxFromDisk('organizations');
    await Hive.deleteBoxFromDisk('invoices');
    
  }
  
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
