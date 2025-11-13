import 'package:flutter/material.dart';
import '../models/settings_model.dart';

class SettingsController extends ChangeNotifier {
  final SettingsModel _model = SettingsModel();

  AppThemeMode get themeMode => _model.themeMode;
  AppColorScheme get colorScheme => _model.colorScheme;
  Map<AppColorScheme, Color> get colorMap => _model.colorMap;

  void setThemeMode(AppThemeMode newMode) {
    if (_model.themeMode != newMode) {
      _model.themeMode = newMode;

      notifyListeners();
    }
  }

  // Método para cambiar el esquema de color
  void setColorScheme(AppColorScheme newColor) {
    if (_model.colorScheme != newColor) {
      _model.colorScheme = newColor;

      notifyListeners();
    }
  }
}
