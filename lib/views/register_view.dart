import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/register_controller.dart';
import 'package:prolab_unimet/widgets/custom_text_field_widget.dart';
import 'package:go_router/go_router.dart';

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
                          setState(() {
                            _autoValidateMode = AutovalidateMode.always;
                          });

                          if (!_controller.validateForm()) return;

                          // Capture NavigatorState, ScaffoldMessengerState and GoRouter before the async gap
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final router = GoRouter.of(context);

                          // Show loading dialog without awaiting so registration runs while dialog is visible
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            // Perform registration (pass State.context directly)
                            await _controller.registerUser(context);

                            // If the state was disposed while registering, stop safely
                            if (!mounted) {
                              _controller.dispose();
                              return;
                            }

                            // Close the dialog using the captured NavigatorState
                            if (navigator.canPop()) {
                              navigator.pop();
                            }

                            // Navigate using the captured GoRouter instance
                            router.go('admin-dashboard');
                          } catch (e) {
                            // Try to close dialog even if an error happens
                            if (navigator.canPop()) {
                              navigator.pop();
                            }

                            // Only show snackbar if the State is still mounted (use captured messenger)
                            if (mounted) {
                              messenger.showSnackBar(
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
        ),
        const SizedBox(height: 20),

        _label('Correo Electrónico'),
        CustomTextField(
          labelText: 'Correo',
          hintText: 'tucorreo@email.com',
          iconData: Icons.email_outlined,
          controller: _controller.emailController,
          validator: _controller.validateEmail,
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
          hintText: '0414 1234567',
          iconData: Icons.phone_android_outlined,
          keyboardType: TextInputType.number,
          controller: _controller.phoneController,
          validator: _controller.validatePhone,
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
          hintText: 'Número de cédula',
          iconData: Icons.assignment_ind_outlined,
          controller: _controller.personIdController,
          validator: _controller.validatePersonId,
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
