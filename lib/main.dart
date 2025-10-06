import 'package:flutter/material.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
//import 'views/register_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Color para el tema
    const Color softGrey = Color(0xFF424242);
    const Color greenBorder = Color(0xFFA5D6A7);
    const Color greenFocus = Color(0xFF66BB6A);

    return MaterialApp(
      title: 'ProLab UNIMET Auth Local',
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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(),
        //'/register': (context) => RegisterView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
