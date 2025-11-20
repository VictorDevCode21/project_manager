// lib/models/help_module_model.dart
import 'package:flutter/material.dart';

class Feature {
  final String title;
  final String description;
  final IconData iconData;
  Feature({
    required this.title,
    required this.description,
    required this.iconData,
  });
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class QuickLink {
  final String title;
  final String routeName; // Para la navegación a otras páginas/módulos

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
        iconData: Icons.bar_chart_outlined,
      ),
      Feature(
        title: 'Gestión de Proyectos',
        description:
            'Crea, edita y administra proyectos. Asigna recursos y establece fechas límite.',
        iconData: Icons.folder_outlined,
      ),
      Feature(
        title: 'Gestión de Tareas',
        description:
            'Organiza tareas por prioridad, estado y fecha. Marca como completadas y realiza seguimiento.',
        iconData: Icons.calendar_today_outlined,
      ),
      Feature(
        title: 'Gestión de Recursos',
        description:
            'Administra tu equipo, asigna roles y distribuye recursos entre proyectos.',
        iconData: Icons.people_outline,
      ),
      Feature(
        title: 'Reportes y Análisis',
        description:
            'Genera reportes detallados sobre el progreso de proyectos y productividad del equipo.',
        iconData: Icons.description_outlined,
      ),
      Feature(
        title: 'Configuración',
        description:
            'Personaliza la apariencia, temas de color y configuraciones de la aplicación.',
        iconData: Icons.settings_outlined,
      ),
    ];
  }

  // Lista de Preguntas Frecuentes
  static List<FaqItem> getFaqs() {
    return [
      FaqItem(
        question: '¿Cómo creo un nuevo proyecto?',
        answer:
            "Ve a la sección 'Proyectos' desde el menú principal y haz clic en 'Nuevo Proyecto'. Completa la información requerida como nombre, descripción, fecha de inicio y fin, y asigna los recursos necesarios.",
      ),
      FaqItem(
        question: '¿Puedo asignar múltiples personas a una tarea?',
        answer:
            'Sí, en la gestión de tareas puedes asignar múltiples miembros del equipo a una sola tarea. Esto es útil para tareas colaborativas que requieren diferentes habilidades.',
      ),
      FaqItem(
        question: '¿Cómo cambio el tema de la aplicación?',
        answer:
            'Ve a Configuración desde el menú principal. Allí encontrarás opciones para cambiar entre tema claro, oscuro o automático, así como diferentes esquemas de colores.',
      ),
      FaqItem(
        question: '¿Puedo exportar los reportes?',
        answer:
            'Sí, todos los reportes pueden ser exportados en formato PDF o Excel. Usa el botón "Exportar" en la parte superior de cada reporte.',
      ),
      FaqItem(
        question: '¿Cómo actualizo mi información personal?',
        answer:
            'Haz clic en "Mi Perfil" en el menú de usuario (esquina superior derecha) y selecciona "Modificar Perfil" para actualizar tu información personal y datos de contacto.',
      ),
      FaqItem(
        question: '¿Qué significan los diferentes estados de las tareas?',
        answer:
            'Las tareas pueden tener los siguientes estados: Pendiente (gris), En Progreso (azul), Completada (verde), y Atrasada (rojo). Estos colores te ayudan a identificar rápidamente el estado de cada tarea.',
      ),
      FaqItem(
        question: '¿Puedo recibir notificaciones sobre mis proyectos?',
        answer:
            'Actualmente las notificaciones están en desarrollo. Pronto podrás configurar alertas para fechas límite, nuevas asignaciones y actualizaciones de proyecto.',
      ),
      FaqItem(
        question: '¿Cómo elimino un proyecto?',
        answer:
            'Ve a la página del proyecto específico y busca la opción "Eliminar Proyecto" en el menú de acciones. Ten cuidado, esta acción no se puede deshacer.',
      ),
    ];
  }

  // Lista de Enlaces Rápidos
  static List<QuickLink> getQuickLinks() {
    return [
      QuickLink(title: 'Crear Nuevo Proyecto', routeName: '/admin-projects'),
      QuickLink(title: 'Agregar Nueva Tarea', routeName: '/admin-tasks'),
      QuickLink(title: 'Asignar Recursos', routeName: '/admin-resources'),
      QuickLink(title: 'Ver Reportes', routeName: '/admin-reports'),
      QuickLink(title: 'Configuración', routeName: '/admin-settings'),
    ];
  }
}
