import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

enum AppColorScheme { blue, green, purple, orange, red, teal }

class SettingsModel {
  AppThemeMode themeMode = AppThemeMode.light;

  AppColorScheme colorScheme = AppColorScheme.blue;

  final Map<AppColorScheme, Color> colorMap = {
    AppColorScheme.blue: const Color(0xff253f8d),
    AppColorScheme.green: Colors.green,
    AppColorScheme.purple: Colors.deepPurple,
    AppColorScheme.orange: Colors.deepOrange,
    AppColorScheme.red: Colors.red,
    AppColorScheme.teal: Colors.teal,
  };
}
