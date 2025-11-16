// lib/models/help_module_model.dart
class Feature {
  final String title;
  final String description;
  final String iconPath;

  Feature({
    required this.title,
    required this.description,
    required this.iconPath,
  });
}

class FaqItem {
  final String question;

  FaqItem({required this.question});
}

class QuickLink {
  final String title;
  final String routeName;

  QuickLink({required this.title, required this.routeName});
}

class HelpData {
  // Lista de Funcionalidades Principales
  static List<Feature> getFeatures() {
    return [
      Feature(
        title: 'Dashboard Principal',
        description:
            'Visualiza métricas clave, proyectos activos y resumen de tareas en tiempo real.',
        iconPath: 'assets/icons/dashboard.png',
      ),
      Feature(
        title: 'Gestión de Proyectos',
        description:
            'Crea, edita y administra proyectos. Asigna recursos y establece fechas límite.',
        iconPath: 'assets/icons/project.png',
      ),
      Feature(
        title: 'Gestión de Tareas',
        description:
            'Organiza tareas por prioridad, estado y fecha. Marca como completadas y realiza seguimiento.',
        iconPath: 'assets/icons/task.png',
      ),
      Feature(
        title: 'Gestión de Recursos',
        description:
            'Administra tu equipo, asigna roles y distribuye recursos entre proyectos.',
        iconPath: 'assets/icons/resource.png',
      ),
      Feature(
        title: 'Reportes y Análisis',
        description:
            'Genera reportes detallados sobre el progreso de proyectos y productividad del equipo.',
        iconPath: 'assets/icons/report.png',
      ),
      Feature(
        title: 'Configuración',
        description:
            'Personaliza la apariencia, temas de color y configuraciones de la aplicación.',
        iconPath: 'assets/icons/settings.png',
      ),
    ];
  }

  // Lista de Preguntas Frecuentes
  static List<FaqItem> getFaqs() {
    return [
      FaqItem(question: '¿Cómo creo un nuevo proyecto?'),
      FaqItem(question: '¿Puedo asignar múltiples personas a una tarea?'),
      FaqItem(question: '¿Cómo cambio el tema de la aplicación?'),
      FaqItem(question: '¿Puedo exportar los reportes?'),
      FaqItem(question: '¿Cómo actualizo mi información personal?'),
      FaqItem(
        question: '¿Qué significan los diferentes estados de las tareas?',
      ),
      FaqItem(question: '¿Puedo recibir notificaciones sobre mis proyectos?'),
      FaqItem(question: '¿Cómo elimino un proyecto?'),
    ];
  }

  // Lista de Enlaces Rápidos
  static List<QuickLink> getQuickLinks() {
    return [
      QuickLink(title: 'Crear Nuevo Proyecto', routeName: '/newProject'),
      QuickLink(title: 'Agregar Nueva Tarea', routeName: '/newTask'),
      QuickLink(title: 'Asignar Recursos', routeName: '/assignResources'),
      QuickLink(title: 'Ver Reportes', routeName: '/viewReports'),
      QuickLink(title: 'Configuración', routeName: '/settings'),
    ];
  }
}
