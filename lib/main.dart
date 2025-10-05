// lib/main.dart

import 'package:flutter/material.dart';
import 'views/landing_page_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProLab UNIMET',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Arial'),
      // La vista se convierte en la home
      home: LandingPageView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
