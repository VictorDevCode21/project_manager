// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prolab_unimet/controllers/task_controller.dart';
import 'package:prolab_unimet/core/routes/app_routes.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:prolab_unimet/providers/notification_provider.dart';
import 'package:prolab_unimet/views/splash_view.dart';
import 'package:provider/provider.dart';
import 'services/firebase_options.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prolab_unimet/controllers/settings_controller.dart';
import 'package:prolab_unimet/models/settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(const HashUrlStrategy());

  try {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado correctamente: ${app.name}');
  } catch (e, st) {
    debugPrint('❌ Error al inicializar Firebase: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    await dotenv.load(fileName: "assets/.env"); // Await to load .env variables
    debugPrint('✅ .env loaded for web: ${dotenv.env.length} vars');
  } catch (e) {
    debugPrint('⚠️ Could not load assets/.env: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => TaskController()),

        // === 🚀 THIS IS THE FIX ===
        // The method name in 'update' must match the method in your NotificationProvider.
        // We named it 'updateUser'.
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, auth, previousNotifier) =>
              previousNotifier!
                ..updateUser(auth), // ⬅️ This was the line to fix
        ),
        // === END OF FIX ===
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Función para mapear el enum interno al ThemeMode de Flutter
  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Función auxiliar para construir la configuración de tema
  ThemeData _buildTheme(Brightness brightness, Color primaryColor) {
    const Color softGrey = Color(0xFF424242);
    const Color greenBorder = Color(0xFFA5D6A7);
    const Color greenFocus = Color(0xFF66BB6A);
    const Color lightBlue = Color(0xFF0D47A1);

    return ThemeData(
      colorSchemeSeed: primaryColor,
      brightness: brightness,
      useMaterial3: true,

      // Color TEXTO
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: brightness == Brightness.light ? softGrey : Colors.white70,
        ),
        bodyMedium: TextStyle(
          color: brightness == Brightness.light ? softGrey : Colors.white70,
        ),
        labelLarge: TextStyle(
          color: brightness == Brightness.light ? softGrey : Colors.white,
        ),
      ),

      // Color ICONOS
      iconTheme: IconThemeData(
        color: brightness == Brightness.light ? softGrey : Colors.white70,
      ),

      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: brightness == Brightness.light ? softGrey : Colors.white70,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        iconColor: brightness == Brightness.light ? softGrey : Colors.white70,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: greenBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: greenBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: greenFocus, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // While session is initializing, show splash
        if (auth.isInitializing) {
          return const MaterialApp(
            home: SplashView(),
            debugShowCheckedModeBanner: false,
          );
        }

        return Builder(
          builder: (settingsContext) {
            final settingsController = settingsContext
                .watch<SettingsController>();
            final primaryColor =
                settingsController.colorMap[settingsController.colorScheme] ??
                Colors.blue;

            return MaterialApp.router(
              title: 'ProLab UNIMET',
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,

              themeMode: _getThemeMode(settingsController.themeMode),
              theme: _buildTheme(Brightness.light, primaryColor),
              darkTheme: _buildTheme(Brightness.dark, primaryColor),
            );
          },
        );
      },
    );
  }
}
