// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_landing_page/core/routes/app_routes.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ProLab UNIMET',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Arial'),
      // This view becomes home
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
