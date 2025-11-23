// help_module_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/help_module_controller.dart';
import '../models/help_module_model.dart';

const Color softGrey = Color(0xFF424242);
const Color cardBorderColor = Color(0xFFE9ECEF);
const Color validationGreen = Color(0xFF4CAF50);

const TextStyle headlineStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);

const TextStyle subtitleStyle = TextStyle(fontSize: 14, color: softGrey);

class HelpModuleView extends StatelessWidget {
  const HelpModuleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpModuleController(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context),
                const SizedBox(height: 20),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _SearchSection(),
                          SizedBox(height: 20),
                          _MainFeaturesSection(),
                          SizedBox(height: 30),
                          _FaqSection(),
                        ],
                      ),
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _NeedHelpSection(),
                          SizedBox(height: 30),
                          _QuickLinksSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themePrimaryColor = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Volver al Dashboard')),
            );
          },
          icon: Icon(Icons.arrow_back, size: 18, color: themePrimaryColor),
          label: Text(
            'Volver al Dashboard',
            style: TextStyle(color: themePrimaryColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Centro de Ayuda',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themePrimaryColor,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Encuentra respuestas a tus preguntas y aprende a usar todas las funcionalidades',
          style: subtitleStyle,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// SECCIÓN DE BÚSQUEDA - APLICANDO BORDE VERDE AL ENFOQUE
// -----------------------------------------------------------------

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HelpModuleController>(
      context,
      listen: false,
    );

    return TextField(
      onChanged: (query) => controller.searchFaqs(query),
      decoration: InputDecoration(
        hintText: 'Buscar en preguntas frecuentes...',
        prefixIcon: const Icon(Icons.search, color: softGrey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cardBorderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: validationGreen, width: 1.0),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// SECCIÓN DE FUNCIONALIDADES PRINCIPALES
// -----------------------------------------------------------------

class _MainFeaturesSection extends StatelessWidget {
  const _MainFeaturesSection();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HelpModuleController>(context);
    final features = controller.features;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: validationGreen.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Funcionalidades Principales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Conoce todas las herramientas disponibles en tu sistema de gestión',
            style: subtitleStyle,
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              return _FeatureCard(feature: features[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: validationGreen.withOpacity(0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  feature.iconData,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feature.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                feature.description,
                style: const TextStyle(fontSize: 12, color: softGrey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// SECCIÓN DE PREGUNTAS FRECUENTES (FAQ)
// -----------------------------------------------------------------

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HelpModuleController>(context);
    final faqs = controller.filteredFaqs;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: validationGreen.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Preguntas Frecuentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Respuestas a las preguntas más comunes sobre el uso de la aplicación',
            style: subtitleStyle,
          ),
          const SizedBox(height: 15),
          Consumer<HelpModuleController>(
            builder: (context, controller, child) {
              final faqs = controller.filteredFaqs;

              if (faqs.isEmpty && controller.searchTerm.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No se encontraron resultados para "${controller.searchTerm}".',
                    style: const TextStyle(color: softGrey),
                  ),
                );
              }

              return Column(
                children: faqs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final faq = entry.value;

                  return _FaqItem(
                    faq: faq,
                    index: index,
                    isExpanded: controller.expandedFaqIndex == index,
                    onTap: controller.toggleFaqExpansion,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final FaqItem faq;
  final int index;
  final bool isExpanded;
  final ValueChanged<int> onTap;
  const _FaqItem({
    required this.faq,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: validationGreen.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: ExpansionTile(
          key: isExpanded
              ? ValueKey('expanded_${faq.question}')
              : ValueKey('closed_${faq.question}'),
          initiallyExpanded: isExpanded,

          onExpansionChanged: (_) {
            onTap(index);
          },

          title: Text(
            faq.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 12.0,
                top: 4.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ),
          ],

          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.primary,
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// SECCIÓN LATERAL DERECHA - ¿Necesitas más ayuda? (Contactos)
// -----------------------------------------------------------------

class _NeedHelpSection extends StatelessWidget {
  const _NeedHelpSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: validationGreen.withOpacity(0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Necesitas más ayuda?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 15),
          _ContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Chat en vivo',
            subtitle: 'Lun-Vie 9:00-18:00',
            color: Theme.of(context).colorScheme.primary,
            onTap: () => _showContactSnackBar(context, 'Proximamente'),
          ),
          const Divider(height: 20, color: cardBorderColor),
          _ContactOption(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'soporte@empresa.com',
            color: Theme.of(context).colorScheme.primary,
            onTap: () => _showContactSnackBar(context, 'Proximamente'),
          ),
          const Divider(height: 20, color: cardBorderColor),
          _ContactOption(
            icon: Icons.phone_outlined,
            title: 'Teléfono',
            subtitle: '+58 212 123-4567',
            color: Theme.of(context).colorScheme.primary,
            onTap: () => _showContactSnackBar(context, 'Proximamente'),
          ),
        ],
      ),
    );
  }

  void _showContactSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: softGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// SECCIÓN LATERAL DERECHA - Enlaces Rápidos
// -----------------------------------------------------------------

class _QuickLinksSection extends StatelessWidget {
  const _QuickLinksSection();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HelpModuleController>(context);
    final quickLinks = controller.quickLinks;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: validationGreen.withOpacity(0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enlaces Rápidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          ...quickLinks.map((link) {
            return InkWell(
              onTap: () => controller.navigateTo(context, link.routeName),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  link.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
