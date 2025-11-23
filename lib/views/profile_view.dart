import 'package:flutter/material.dart';
import 'package:prolab_unimet/widgets/custom_text_field_widget.dart';
import 'package:prolab_unimet/controllers/profile_controller.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavButton1(
            icon: Icons.arrow_back,
            label: 'Volver al dashboard',
            route: '/admin-dashboard',
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            'Modificar Perfil',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 28,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),

          Text(
            'Actualiza tu información personal y datos de contacto',
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 40),
          ProfileManager(),
        ],
      ),
    );
  }
}

class ComeBackButton extends StatelessWidget {
  const ComeBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Modificar Perfil',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 28,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Actualiza tu información personal y datos de contacto',
          textAlign: TextAlign.left,
        ),
        ProfileManager(),
      ],
    );
  }
}

class ProfileManager extends StatefulWidget {
  const ProfileManager({super.key});

  @override
  State<ProfileManager> createState() => _ProfileManagerState();
}

class _ProfileManagerState extends State<ProfileManager> {
  late final ProfileController controller;
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = ProfileController();

    // Load current user data once after first build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.cancelarAccion(context);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_2_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  'Informacion personal',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Row(
              children: const [
                Text('Actualiza tu información personal y datos de contacto'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 55,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _profileFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: column1()),
                  const SizedBox(width: 30),
                  Expanded(child: column2()),
                ],
              ),
            ),
            descriptionBox(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                cancel1(),
                const SizedBox(width: 10),
                saveChanges(),
                const SizedBox(width: 10),
                authChange(),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget column1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre completo',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomTextField(
          labelText: 'nombre',
          hintText: 'Tu nombre completo',
          iconData: Icons.person,
          controller: controller.newnameController,
          validator: controller.validarNombre,
        ),
        const SizedBox(height: 10),
        Text(
          'Teléfono',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomTextField(
          labelText: 'telefono',
          hintText: '04141234567',
          iconData: Icons.phone,
          controller: controller.newphoneController,
          validator: controller.validarPhone,
        ),
      ],
    );
  }

  Widget column2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cédula',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomTextField(
          labelText: 'cedula',
          hintText: 'Número de cédula',
          iconData: Icons.info,
          controller: controller.newpersonIdController,
          validator: controller.validarCedula,
        ),
        const SizedBox(height: 10),
        Text(
          'Fecha de nacimiento',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime firstDate = DateTime(
              now.year - 120,
              now.month,
              now.day,
            );

            final DateTime? pickedDate = await showDatePicker(
              context: context,
              firstDate: firstDate,
              initialDate: controller.selectedDate ?? DateTime(2000),
              lastDate: now,
            );
            if (pickedDate != null) {
              setState(() => controller.selectedDate = pickedDate);
            }
          },
          controller: TextEditingController(
            text: controller.selectedDate == null
                ? ''
                : '${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}',
          ),
          validator: (_) => controller.validarDate(),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget descriptionBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción personal',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextField(controller: controller.descController, maxLines: 10),
        ],
      ),
    );
  }

  Widget cancel1() {
    return OutlinedButton(
      onPressed: () async {
        try {
          await controller.cancelarAccion(context);
          if (mounted) setState(() {});
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      child: const Text('Cancelar'),
    );
  }

  Widget saveChanges() {
    return TextButton.icon(
      onPressed: () async {
        if (!mounted) return;
        try {
          await controller.modificarPerfil(context);
          if (mounted) setState(() {});
        } catch (e) {
          debugPrint('[ProfileManager] saveChanges error: $e');
        }
      },
      icon: Icon(Icons.save, color: Theme.of(context).colorScheme.onPrimary),
      label: Text(
        'Guardar cambios',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget authChange() {
    return TextButton.icon(
      onPressed: () {
        if (!mounted) return;
        try {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const ModificarAuth(),
            ),
          );
        } catch (e) {
          debugPrint('Error: $e');
        }
      },
      icon: Icon(
        Icons.app_registration_rounded,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      label: Text(
        'Modificar autenticación',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

//Boton de navegación con algunos cambios
class NavButton1 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color? color;

  const NavButton1({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.go(route),
      icon: Icon(icon, color: Theme.of(context).textTheme.bodyMedium!.color),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontWeight: FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

class ModificarAuth extends StatefulWidget {
  const ModificarAuth({super.key});

  @override
  State<ModificarAuth> createState() => _ModificarAuthState();
}

class _ModificarAuthState extends State<ModificarAuth> {
  ProfileController controller = ProfileController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                label: const Text(
                  'Volver',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Text(
                    'Modificar datos de inicio de sesión',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    'Modificar los datos del correo y contraseña',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 25),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Form(
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.app_registration_rounded,
                        size: 50,
                        color: Colors.indigo,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datos de inicio de sesión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            'Modificar los datos del correo y contraseña',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.app_registration_rounded,
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  Text(
                    'Antiguo Correo',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomTextField(
                    labelText: 'oldemail',
                    controller: controller.oldemailController,
                    validator: controller.validarCorreo,
                  ),
                  Text(
                    'Nuevo correo',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomTextField(
                    labelText: 'newemail',
                    controller: controller.newemailController,
                    validator: controller.validarCorreo,
                  ),
                  Text(
                    'Antigua contraseña',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomTextField(
                    labelText: 'oldpassword',
                    controller: controller.oldpasswordController,
                    validator: controller.validarPassword,
                  ),
                  Text(
                    'Nueva contraseña',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomTextField(
                    labelText: 'newpassword',
                    controller: controller.newpasswordController,
                    validator: controller.validarPassword,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              try {
                controller.modificarLogin(context);
              } catch (e) {}
            },
            icon: Icon(
              Icons.save,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              'Guardar cambios',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}
