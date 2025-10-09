// lib/main.dart

import 'package:flutter/material.dart';
import 'views/landing_page_view.dart';

void main() {
  runApp(const MyApp());
import 'package:firebase_core/firebase_core.dart';
import 'package:web_project_manager/core/routes/app_routes.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProLab UNIMET',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Arial'),
      // La vista se convierte en la home
      home: LandingPageView(),
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Project Manager',
      debugShowCheckedModeBanner: false,
    );
  }
}
