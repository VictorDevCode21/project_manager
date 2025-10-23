import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final IconData iconData;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.iconData,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Detecta si el formulario ya fue validado (es decir, el usuario presionó "Crear cuenta")
    final form = Form.of(context);
    final showErrors =
        form.widget.autovalidateMode != AutovalidateMode.disabled;

    // Calcula manualmente el texto de error solo si ya se validó
    final errorText = showErrors && validator != null
        ? validator!(controller?.text)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contenedor fijo para el input
        Container(
          height: 45,
          alignment: Alignment.center,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            // No usar el sistema interno de error de Flutter (oculto)
            validator: (_) => null,
            decoration: InputDecoration(
              prefixIcon: Icon(iconData),
              hintText: hintText,
              errorText: null, // anulamos el manejo de error automático
              errorStyle: const TextStyle(height: 0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 164, 205, 191),
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 164, 205, 191),
                  width: 1.5,
                ),
              ),
              // Solo cambia el borde a rojo si hay error, pero sin afectar el layout
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: errorText != null
                      ? Colors.red
                      : const Color.fromARGB(255, 164, 205, 191),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Espacio fijo para error debajo
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: SizedBox(
            height: 16, // mantiene simetría entre todos los campos
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorText ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
