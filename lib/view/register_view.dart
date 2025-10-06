import 'package:flutter/material.dart';
import 'package:web_project_manager/widgets/customTextField_Widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String? selectedRole;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xfff4f6f7),
          body: Center(
            child: SizedBox(
              width: 1000,
              height: 1500,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    color: Color(0xffffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 300),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                //Icon
                                Image.asset(
                                  'assets/images/ProlabIcon.png',
                                  width: 100,
                                  height: 100,
                                ),

                                SizedBox(height: 10),

                                //Create account
                                Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff253f8d),
                                  ),
                                ),

                                //Join us
                                Text(
                                  'Únete a ProLab UNIMET',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 113, 123, 136),
                                  ),
                                ),
                                SizedBox(height: 60, width: 40),

                                //Inputs
                                SizedBox(
                                  width: 700,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child:
                                            //Column 1 - left
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Nombre Completo'),
                                                const SizedBox(height: 6),

                                                SizedBox(
                                                  //width: 340,
                                                  height: 41,
                                                  child: CustomTextField(
                                                    labelText: ('Nombre'),
                                                    hintText: 'Jhon Doe',
                                                    iconData:
                                                        Icons.person_2_outlined,
                                                  ),
                                                ),
                                                const SizedBox(height: 30),

                                                Text('Correo Electrónico'),
                                                const SizedBox(height: 6),
                                                SizedBox(width: 320),
                                                SizedBox(
                                                  //width: 340,
                                                  height: 41,
                                                  child: CustomTextField(
                                                    labelText: ('Email'),
                                                    hintText: 'tu@email.com',
                                                    iconData:
                                                        Icons.email_outlined,
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                  ),
                                                ),

                                                const SizedBox(height: 30),
                                                Text('Contraseña'),
                                                const SizedBox(height: 6),
                                                SizedBox(width: 320),
                                                SizedBox(
                                                  height: 41,
                                                  child: CustomTextField(
                                                    labelText: ('Contraseña'),
                                                    hintText: '••••••••',
                                                    iconData:
                                                        Icons.lock_outline,
                                                    obscureText: true,
                                                    controller:
                                                        passwordController,
                                                  ),
                                                ),

                                                const SizedBox(height: 30),

                                                Text('Confirmar Contraseña'),
                                                const SizedBox(height: 6),
                                                SizedBox(width: 320),
                                                SizedBox(
                                                  height: 41,
                                                  child: CustomTextField(
                                                    labelText:
                                                        ('Confirmar Contraseña'),
                                                    hintText:
                                                        'Repite tu contraseña',
                                                    iconData:
                                                        Icons.lock_outline,
                                                    obscureText: true,
                                                    controller:
                                                        confirmPasswordController,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      ),

                                      SizedBox(width: 45),

                                      //Column 2 - right
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Teléfono'),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              //width: 340,
                                              height: 41,
                                              child: CustomTextField(
                                                labelText: ('Teléfono'),
                                                hintText: '0414 1234567',
                                                iconData: Icons
                                                    .phone_android_outlined,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),

                                            const SizedBox(height: 30),

                                            Text('Tipo de usuario'),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              //width: 340,
                                              height: 41,
                                              child: DropdownButtonFormField<String>(
                                                decoration:
                                                    const InputDecoration(
                                                      prefixIcon: Icon(
                                                        Icons.person_4_outlined,
                                                      ),
                                                      hintText:
                                                          'Selecciona un rol',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 'Coordinador',
                                                    child: Text('Coordinador'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Usuario',
                                                    child: Text('Usuario'),
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedRole =
                                                        value; // Guardar el rol seleccionado
                                                  });
                                                },
                                                value:
                                                    selectedRole, // Mantiene el valor seleccionado
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
