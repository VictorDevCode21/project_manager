// lib/controllers/dashboard_controller.dart

import 'package:flutter/material.dart';
import '../models/dashboard_model.dart'; // Asegúrate de que la ruta sea correcta

class DashboardController extends ChangeNotifier {
  DashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los datos iniciales del dashboard.
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simula el retraso de una llamada de red
      await Future.delayed(const Duration(seconds: 1));

      // En una app real: _dashboardData = await YourApiService.fetchDashboardData();
      _dashboardData = DashboardModel.loadSampleData();
    } catch (e) {
      _errorMessage = 'Error al cargar los datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para manejar interacciones (Ej: exportar, cambiar rango de tiempo)
  void exportData() {
    // Lógica para exportar los datos...
    print('Datos exportados');
    // Muestra un SnackBar o diálogo de éxito/error
  }

  void changeTimeRange(String newRange) {
    // Lógica para recargar los datos con un nuevo rango de tiempo...
    print('Rango de tiempo cambiado a: $newRange');
    // loadDashboardData(range: newRange);
  }

  // Puedes agregar más lógica aquí, como la navegación entre pestañas
}
