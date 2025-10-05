// lib/views/landing_page_view.dart

import 'package:flutter/material.dart';
import '../controllers/landing_controller.dart';
import 'components/feature_card.dart';
import 'components/benefit_card.dart';
import 'components/result_item.dart';
import 'components/footer_column.dart';
import '../models/feature_model.dart';

class LandingPageView extends StatelessWidget {
  LandingPageView({Key? key}) : super(key: key);

  // Instancia del controlador para acceder a los datos y acciones
  final LandingController _controller = LandingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(),
            _buildWhyChooseUsSection(),
            _buildModulesSection(),
            _buildCTASection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- Secciones de la Vista ---

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(
            'fondo_edificio.png',
          ), // Asegúrate de tener este asset
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.blue.shade900.withOpacity(0.1),
            BlendMode.overlay,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50.withOpacity(0.8),
            Colors.white.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 24.0, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Transforma la Gestión de tus ',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Proyectos',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'La plataforma integral que necesitas para gestionar proyectos de consultoría,\n optimizar recursos y maximizar resultados con herramientas profesionales.',
            style: TextStyle(fontSize: 18, color: Colors.white, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 900,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        // Llama a la acción del controlador
                        onPressed: _controller.onStartProjectPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Quiero iniciar a crear mi primer proyecto →',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        // Llama a la acción del controlador
                        onPressed: _controller.onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            'Funcionalidades Poderosas para Proyectos Exitosos',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Descubre las herramientas que harán que tu gestión de proyectos sea más eficiente, organizada y profesional que nunca.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            // Usa los datos del controlador para construir las tarjetas
            children: _controller.features
                .map((f) => FeatureCard(model: f))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Text(
            '¿Por qué elegir ProLab UNIMET?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Más que un simple gestor de proyectos, somos tu socio estratégico para alcanzar la excelencia operacional y maximizar el éxito de cada proyecto.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            // Usa los datos del controlador para construir las tarjetas
            children: _controller.benefits
                .map((b) => BenefitCard(model: b))
                .toList(),
          ),
          const SizedBox(height: 60),
          Text(
            'Resultados Comprobados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Wrap(
              spacing: 40,
              runSpacing: 20,
              alignment: WrapAlignment.spaceAround,
              children: [
                ResultItem(
                  percentage: '40%',
                  description: 'Reducción en tiempos de gestión',
                ),
                ResultItem(
                  percentage: '95%',
                  description: 'Satisfacción de usuarios',
                ),
                ResultItem(
                  percentage: '60%',
                  description: 'Mejora en productividad',
                ),
                ResultItem(
                  percentage: '100%',
                  description: 'Proyectos entregados a tiempo',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            'Módulos Especializados para Cada Necesidad',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Explora todos los módulos disponibles en la plataforma administrativa, diseñados específicamente para optimizar cada aspecto de tu gestión.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            children: _controller.modules.map(_buildModuleCard).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel model) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            model.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...model.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade900, Colors.blue.shade700],
        ),
      ),
      child: Column(
        children: [
          Text(
            '¿Listo para Revolucionar\ntu Gestión de Proyectos?',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Únete a cientos de profesionales que ya están transformando su forma de trabajar con ProLab UNIMET.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              ElevatedButton(
                // Llama a la acción del controlador
                onPressed: _controller.onCTAPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Comenzar Ahora - Es Gratis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton(
                // Llama a la acción del controlador
                onPressed: _controller.onViewFeaturesPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ver Funcionalidades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          const Text(
            'ProLab UNIMET',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sistema de Gestión de Proyectos para Laboratorios de Ingeniería - Universidad Metropolitana. Transformando la manera de gestionar proyectos profesionales.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          const Wrap(
            spacing: 40,
            runSpacing: 20,
            children: [
              FooterColumn(
                title: 'Enlaces Rápidos',
                items: ['Ayuda', 'Iniciar Sesión', 'Registrarse'],
              ),
              FooterColumn(
                title: 'Síguenos',
                items: [
                  'Email: soporte@prolab.unimet.edu.ve',
                  'Teléfono: +58 212 240-1111',
                  'Universidad Metropolitana',
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Divider(color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            '© 2024 ProLab UNIMET. Todos los derechos reservados.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
