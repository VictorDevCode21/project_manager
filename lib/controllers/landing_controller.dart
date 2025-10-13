// lib/controllers/landing_controller.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/feature_model.dart';

class LandingController {
  // --- Datos del Modelo ---

  final List<FeatureModel> features = [
    FeatureModel(
      title: 'Gestión de Proyectos',
      description:
          'Crea, organiza y monitoriza proyectos de consultoría con herramientas avanzadas de planificación y seguimiento en tiempo real.',
      icon: Icons.assignment,
    ),
    FeatureModel(
      title: 'Dashboard Inteligente',
      description:
          'Visualiza métricas clave, progreso de proyectos y KPIs importantes a través de dashboards interactivos y personalizables.',
      icon: Icons.dashboard,
    ),
    FeatureModel(
      title: 'Gestión de Tareas',
      description:
          'Asigna tareas específicas, establece fechas límite y monitorea el progreso de cada actividad dentro de los proyectos.',
      icon: Icons.task,
    ),
    FeatureModel(
      title: 'Reportes Avanzados',
      description:
          'Genera reportes detallados y análisis profundos para tomar decisiones informadas basadas en datos reales.',
      icon: Icons.analytics,
    ),
    FeatureModel(
      title: 'Gestión de Recursos',
      description:
          'Administra eficientemente personal, equipos y materiales, optimizando la asignación de recursos en cada proyecto.',
      icon: Icons.people,
    ),
    FeatureModel(
      title: 'Seguridad Empresarial',
      description:
          'Protege tu información con sistemas de seguridad de nivel empresarial y control de acceso granular.',
      icon: Icons.security,
    ),
  ];

  final List<FeatureModel> benefits = [
    FeatureModel(
      title: 'Aumenta la Productividad',
      description:
          'Optimiza flujos de trabajo y reduce tiempos de gestión hasta en un 40%.',
      icon: Icons.trending_up,
    ),
    FeatureModel(
      title: 'Ahorra Tiempo',
      description:
          'Automatiza procesos repetitivos y centraliza toda la información del proyecto.',
      icon: Icons.access_time_filled,
    ),
    FeatureModel(
      title: 'Mejora la Precisión',
      description:
          'Reduce errores y mejora la calidad de entregables con controles integrados.',
      icon: Icons.precision_manufacturing,
    ),
    FeatureModel(
      title: 'Escalabilidad',
      description:
          'Crece sin límites, desde proyectos pequeños hasta operaciones empresariales.',
      icon: Icons.scale,
    ),
  ];

  final List<ModuleModel> modules = [
    ModuleModel(
      title: 'Proyectos',
      subtitle: 'Gestión completa del ciclo de vida de proyectos',
      features: [
        'Creación de proyectos',
        'Seguimiento de progreso',
        'Gestión de entregables',
        'Control de calidad',
      ],
    ),
    ModuleModel(
      title: 'Tareas',
      subtitle: 'Organización y asignación de actividades',
      features: [
        'Asignación de tareas',
        'Fechas límites',
        'Dependencias',
        'Notificaciones automáticas',
      ],
    ),
    ModuleModel(
      title: 'Recursos',
      subtitle: 'Optimización de personal y materiales',
      features: [
        'Gestión de personal',
        'Control de equipos',
        'Inventario de materiales',
        'Planificación de recursos',
      ],
    ),
    ModuleModel(
      title: 'Reportes',
      subtitle: 'Análisis y métricas avanzadas',
      features: [
        'Reportes personalizados',
        'Análisis de rendimiento',
        'Métricas de productividad',
        'Exportación de datos',
      ],
    ),
    ModuleModel(
      title: 'Dashboard',
      subtitle: 'Visualización en tiempo real',
      features: [
        'Métricas en vivo',
        'Gráficos interactivos',
        'Alertas personalizadas',
        'Vista panorámica',
      ],
    ),
    ModuleModel(
      title: 'Configuración',
      subtitle: 'Personalización del sistema',
      features: [
        'Tareas personalizables',
        'Configuración de usuarios',
        'Permisos granulares',
        'Integraciones',
      ],
    ),
  ];

  // --- Lógica de Acciones (Simuladas) ---

  void onStartProjectPressed(BuildContext context) {
    // Lógica para navegar a la página de creación de proyecto o registrar
    context.go('/register');
  }

  void onLoginPressed(BuildContext context) {
    // Lógica para navegar a la página de inicio de sesión
    context.go('/login');
  }

  void onCTAPressed() {
    // Lógica para navegar a la página de registro
    debugPrint('Acción: Comenzar Ahora - Es Gratis');
  }

  void onViewFeaturesPressed() {
    // Lógica para mostrar las funcionalidades
    debugPrint('Acción: Ver Funcionalidades');
  }

  // En un controlador real, estas funciones harían llamadas a servicios o al backend
}
