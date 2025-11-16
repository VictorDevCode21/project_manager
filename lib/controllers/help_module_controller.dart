// lib/controllers/help_module_controller.dart

import 'package:flutter/material.dart';
import '../models/help_module_model.dart';

class HelpModuleController extends ChangeNotifier {
  final List<Feature> _features = HelpData.getFeatures();
  final List<FaqItem> _faqs = HelpData.getFaqs();
  final List<QuickLink> _quickLinks = HelpData.getQuickLinks();

  // Getters para acceder a los datos
  List<Feature> get features => _features;
  List<FaqItem> get faqs => _faqs;
  List<QuickLink> get quickLinks => _quickLinks;

  List<FaqItem> _filteredFaqs = HelpData.getFaqs();
  List<FaqItem> get filteredFaqs => _filteredFaqs;

  void searchFaqs(String query) {
    if (query.isEmpty) {
      _filteredFaqs = _faqs;
    } else {
      _filteredFaqs = _faqs
          .where(
            (faq) => faq.question.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    // Notifica a la vista para que se reconstruya con los nuevos datos
    notifyListeners();
  }

  // Lógica de navegación para Enlaces Rápidos (simulación)
  void navigateTo(BuildContext context, String routeName) {
    // Aquí se implementaría la lógica de navegación real, por ejemplo:
    // Navigator.pushNamed(context, routeName);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navegando a la ruta: $routeName')));
    print('Intentando navegar a: $routeName');
  }

  void handleFaqTap(BuildContext context, String question) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(question),
          content: const Text(
            'Esta es la respuesta a la pregunta seleccionada. se cargaría el contenido completo.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
