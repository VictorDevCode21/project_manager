import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/register_controller.dart';
import 'package:prolab_unimet/widgets/custom_text_field_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterController _controller = RegisterController();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screen.width > 1000 ? 900 : screen.width * 0.95,
            ),
            child: Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/ProlabIcon.png',
                        width: 90,
                        height: 90,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Crear Cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff253f8d),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Únete a ProLab UNIMET',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xff717b88)),
                    ),
                    const SizedBox(height: 30),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        return Form(
                          key: _controller.formKey,
                          autovalidateMode: _autoValidateMode,
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildLeftColumn()),
                                    const SizedBox(width: 30),
                                    Expanded(child: _buildRightColumn()),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLeftColumn(),
                                    const SizedBox(height: 20),
                                    _buildRightColumn(),
                                  ],
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Turn on autovalidation on first submit attempt
                          setState(
                            () => _autoValidateMode = AutovalidateMode.always,
                          );

                          // Dismiss keyboard to ensure field values are up-to-date
                          FocusScope.of(context).unfocus();

                          // Validate the whole form now
                          final isValid =
                              _controller.formKey.currentState?.validate() ??
                              false;

                          // Also validate role/date which live in controller state
                          final roleError = _controller.validateRole();
                          final dateError = _controller.validateDate();

                          // If anything is wrong, just show errors in red and bail. No loader, no navigation.
                          if (!isValid ||
                              roleError != null ||
                              dateError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Corrige los errores antes de continuar.',
                                ),
                              ),
                            );
                            return;
                          }

                          // Optionally save
                          _controller.formKey.currentState?.save();

                          // Now show loader, because we are actually going to hit the network
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final navigator = Navigator.of(context);
                          final router = GoRouter.of(context);

                          try {
                            // Make the controller return a bool indicating success
                            final success = await _controller.registerUser(
                              context,
                            );

                            if (context.mounted && navigator.canPop()) {
                              navigator.pop(); // close loader
                            }

                            if (context.mounted) {
                              router.go(
                                '/admin-dashboard',
                              ); // only navigate if it really succeeded
                            }
                          } catch (e) {
                            if (navigator.canPop()) navigator.pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff253f8d),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () =>
                            context.go('/login'), // o context.push('/login')
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión aquí',
                          style: TextStyle(
                            color: Color(0xff253f8d),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LEFT COLUMN
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nombre Completo'),
        CustomTextField(
          labelText: 'Nombre',
          hintText: 'Jhon Doe',
          iconData: Icons.person_outline,
          controller: _controller.nameController,
          validator: _controller.validateName,
          // Allow only letters (including accents) and spaces; capitalize words
          inputFormatters: [
            FilteringTextInputFormatter.deny(
              RegExp(r'[^a-zA-ZÀ-ÿ\s]'),
            ), // block digits/symbols
            LengthLimitingTextInputFormatter(60), // reasonable cap
          ],
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        _label('Correo Electrónico'),
        CustomTextField(
          labelText: 'Correo',
          hintText: 'johndoe@unimet.edu.ve',
          iconData: Icons.email_outlined,
          controller: _controller.emailController,
          validator: _controller.validateEmail,
          // Force lowercase and remove spaces as the user types
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')), // no spaces
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Convert to lowercase while typing
              return newValue.copyWith(
                text: newValue.text.toLowerCase(),
                selection: newValue.selection,
                composing: TextRange.empty,
              );
            }),
            LengthLimitingTextInputFormatter(80),
          ],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        _label('Contraseña'),
        CustomTextField(
          labelText: 'Contraseña',
          hintText: '••••••••',
          iconData: Icons.lock_outline,
          obscureText: true,
          controller: _controller.passwordController,
          validator: _controller.validatePassword,
          // Block whitespace; no suggestions/autocorrect for passwords
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(64), // cap for sanity
          ],
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        _label('Confirmar Contraseña'),
        CustomTextField(
          labelText: 'Confirmar Contraseña',
          hintText: 'Repite tu contraseña',
          iconData: Icons.lock_outline,
          obscureText: true,
          controller: _controller.confirmPasswordController,
          validator: _controller.validateConfirmPassword,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(64),
          ],
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  // RIGHT COLUMN
  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Teléfono'),
        CustomTextField(
          labelText: 'Teléfono',
          hintText: '04141234567',
          iconData: Icons.phone_android_outlined,
          controller: _controller.phoneController,
          validator:
              _controller.validatePhone, // usa el regex de 0+prefix+7 dígitos
          // Only digits and exactly 11 characters (0 + 3-digit prefix + 7 digits)
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        _label('Tipo de Usuario'),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_4_outlined),
            hintText: 'Selecciona un rol',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: const [
            DropdownMenuItem(value: 'COORDINATOR', child: Text('Coordinador')),
            DropdownMenuItem(value: 'USER', child: Text('Usuario')),
          ],
          initialValue: _controller.selectedRole,
          onChanged: (value) =>
              setState(() => _controller.selectedRole = value),
          validator: (_) => _controller.validateRole(),
        ),
        const SizedBox(height: 38),

        _label('Cédula'),
        CustomTextField(
          labelText: 'Cédula',
          hintText: '30123456',
          iconData: Icons.assignment_ind_outlined,
          controller: _controller.personIdController,
          validator: _controller.validatePersonId,
          // Only digits; typical cap at 10 per your validator
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        _label('Fecha de Nacimiento'),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(1950),
              initialDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() => _controller.selectedDate = pickedDate);
            }
          },
          controller: TextEditingController(
            text: _controller.selectedDate == null
                ? ''
                : '${_controller.selectedDate!.day}/${_controller.selectedDate!.month}/${_controller.selectedDate!.year}',
          ),
          validator: (_) => _controller.validateDate(),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Color(0xff707a72),
      ),
    ),
  );
}
