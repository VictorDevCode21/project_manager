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

  @override
  Widget build(BuildContext context) {
    const Color softGrey = Color(0xFF424242);
    const Color greenBorder = Color(0xFFA5D6A7);
    const Color greenFocus = Color(0xFF66BB6A);

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // While session is initializing, show splash
        if (auth.isInitializing) {
          return const MaterialApp(
            home: SplashView(),
            debugShowCheckedModeBanner: false,
          );
        }

        return MaterialApp.router(
          title: 'ProLab UNIMET',
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF0D47A1),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(0xFF0D47A1, const <int, Color>{
                50: Color(0xFFE3F2FD),
                100: Color(0xFFBBDEFB),
                200: Color(0xFF90CAF9),
                300: Color(0xFF64B5F6),
                400: Color(0xFF42A5F5),
                500: Color(0xFF2196F3),
                600: Color(0xFF1E88E5),
                700: Color(0xFF1976D2),
                800: Color(0xFF1565C0),
                900: Color(0xFF0D47A1),
              }),
            ).copyWith(secondary: const Color(0xFFFF9800)),

            // Color TEXTO
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: softGrey),
              bodyMedium: TextStyle(color: softGrey),
              labelLarge: TextStyle(color: softGrey),
            ),

            // Color ICONOS
            iconTheme: const IconThemeData(color: softGrey),

            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: softGrey),
              hintStyle: TextStyle(color: Colors.grey.shade400),

              iconColor: softGrey,
              // Color BORDES
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
          ),
        );
      },
    );
  }
}
