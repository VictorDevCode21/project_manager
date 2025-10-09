import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:web_project_manager/core/routes/app_routes.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Project Manager',
      debugShowCheckedModeBanner: false,
    );
  }
}
