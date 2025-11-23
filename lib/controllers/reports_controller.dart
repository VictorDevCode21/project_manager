// lib/controllers/reports_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:prolab_unimet/models/projects_model.dart';
import 'package:prolab_unimet/models/reports_model.dart';

/// Controller responsible for loading summary stats and generating reports.
class ReportsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportsModel _model = const ReportsModel();

  ReportsModel get model => _model;

  /// Updates the internal model and notifies listeners.
  void _updateModel(ReportsModel newModel) {
    _model = newModel;
    notifyListeners();
  }

  /// Loads basic statistics for all projects from Firestore.
  Future<void> loadReportsSummary() async {
    _updateModel(_model.copyWith(isLoading: true, errorMessage: null));

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('projects')
          .get();

      // Uses your existing Project.fromDoc factory.
      final List<Project> projects = snapshot.docs
          .map((doc) => Project.fromDoc(doc))
          .toList();

      final int total = projects.length;
      final int completed = projects
          .where((p) => p.status == ProjectStatus.completed)
          .length;
      final int inProgress = projects
          .where((p) => p.status == ProjectStatus.inProgress)
          .length;
      final int planning = projects
          .where((p) => p.status == ProjectStatus.planning)
          .length;

      double averageBudget = 0.0;
      if (projects.isNotEmpty) {
        final double totalBudget = projects.fold<double>(
          0.0,
          (sum, p) => sum + p.budgetUsd,
        );
        averageBudget = totalBudget / projects.length;
      }

      _updateModel(
        _model.copyWith(
          isLoading: false,
          errorMessage: null,
          projects: projects,
          totalProjects: total,
          completedProjects: completed,
          inProgressProjects: inProgress,
          planningProjects: planning,
          averageBudgetUsd: averageBudget,
        ),
      );
    } catch (e) {
      _updateModel(
        _model.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Returns the current list of projects. If empty, fetches from backend.
  Future<List<Project>> fetchProjectsForReport() async {
    if (_model.projects.isNotEmpty) {
      return _model.projects;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('projects')
          .get();

      final List<Project> projects = snapshot.docs
          .map((doc) => Project.fromDoc(doc))
          .toList();

      _updateModel(_model.copyWith(projects: projects));
      return projects;
    } catch (_) {
      return [];
    }
  }

  /// Generates a PDF report for a single project and opens the print/share dialog.
  Future<void> generateProjectReportPdf(
    BuildContext context,
    Project project,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando reporte en PDF...')),
      );

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) {
            return _buildProjectReportPage(project);
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Builds the content of the PDF report using similar structure as ProjectDetailsDialog.
  pw.Widget _buildProjectReportPage(Project project) {
    final (statusLabel, statusColor) = _statusUi(project);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Reporte de Proyecto',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          project.name.isEmpty ? 'Sin título' : project.name,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        // Status + tags row
        pw.Row(
          children: [
            _chipPdf(statusLabel, bg: statusColor),
            if (project.consultingType.isNotEmpty) ...[
              pw.SizedBox(width: 6),
              _chipPdf(
                project.consultingType,
                bg: PdfColor.fromInt(0xFFE8F5E9),
              ),
            ],
            if (project.priority == ProjectPriority.high) ...[
              pw.SizedBox(width: 6),
              _chipPdf('Alta', bg: PdfColor.fromInt(0xFFFFEBEE)),
            ],
            if (project.priority == ProjectPriority.medium) ...[
              pw.SizedBox(width: 6),
              _chipPdf('Media', bg: PdfColor.fromInt(0xFFFFF3E0)),
            ],
            if (project.priority == ProjectPriority.low) ...[
              pw.SizedBox(width: 6),
              _chipPdf('Baja', bg: PdfColor.fromInt(0xFFE3F2FD)),
            ],
          ],
        ),
        pw.SizedBox(height: 16),

        pw.Text(
          'Descripción',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Text(
            project.description.isNotEmpty
                ? project.description
                : 'Sin descripción.',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
        pw.SizedBox(height: 16),

        pw.Divider(),
        pw.SizedBox(height: 12),

        // Two columns with key data
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _kvPdf('Cliente', project.client),
                  _kvPdf(
                    'Presupuesto',
                    '\$${project.budgetUsd.toStringAsFixed(2)}',
                  ),
                  _kvPdf('Inicio', _formatDate(project.startDate)),
                  _kvPdf('Entrega', _formatDate(project.endDate)),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _kvPdf('Propietario (UID)', project.ownerId),
                  _kvPdf('ID del proyecto', project.id),
                  _kvPdf('Creado', _formatDate(project.createdAt)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Returns status label and a soft background color used in tags in PDF.
  (String, PdfColor) _statusUi(Project project) {
    switch (project.status) {
      case ProjectStatus.planning:
        return ('Planificación', PdfColor.fromInt(0xFFFFF3E0));
      case ProjectStatus.inProgress:
        return ('En Progreso', PdfColor.fromInt(0xFFE3F2FD));
      case ProjectStatus.completed:
        return ('Completado', PdfColor.fromInt(0xFFE8F5E9));
      case ProjectStatus.archived:
        return ('Archivado', PdfColor.fromInt(0xFFE0E0E0));
    }
  }

  /// PDF helper for a small rounded badge.
  pw.Widget _chipPdf(String label, {PdfColor? bg}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg ?? PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  /// PDF helper for key-value rows.
  pw.Widget _kvPdf(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              key,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            flex: 6,
            child: pw.Text(
              value.isEmpty ? '—' : value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime to dd/mm/yyyy style.
  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yy = date.year.toString();
    return '$dd/$mm/$yy';
  }
}
