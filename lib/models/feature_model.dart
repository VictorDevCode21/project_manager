// lib/models/feature_model.dart

import 'package:flutter/material.dart';

// Modelo para las Tarjetas de Características
class FeatureModel {
  final String title;
  final String description;
  final IconData icon;

  FeatureModel({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Modelo para los Módulos
class ModuleModel {
  final String title;
  final String subtitle;
  final List<String> features;

  ModuleModel({
    required this.title,
    required this.subtitle,
    required this.features,
  });
}
