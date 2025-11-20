// lib/controllers/help_module_controller.dart

import 'package:flutter/material.dart';
import '../models/help_module_model.dart';
import 'package:go_router/go_router.dart';

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

  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  int? _expandedFaqIndex;
  int? get expandedFaqIndex => _expandedFaqIndex;

  void toggleFaqExpansion(int index) {
    if (_expandedFaqIndex == index) {
      _expandedFaqIndex = null;
    } else {
      _expandedFaqIndex = index;
    }
    notifyListeners();
  }

  void searchFaqs(String query) {
    final cleanQuery = query.trim().toLowerCase();
    _searchTerm = cleanQuery;

    if (cleanQuery.isEmpty) {
      _filteredFaqs = _faqs;
    } else {
      _filteredFaqs = _faqs
          .where(
            (faq) =>
                faq.question.toLowerCase().contains(cleanQuery) ||
                faq.answer.toLowerCase().contains(cleanQuery),
          )
          .toList();
    }

    _expandedFaqIndex = null;
    notifyListeners();
  }

  void navigateTo(BuildContext context, String routeName) {
    GoRouter.of(context).go(routeName);
  }
}
