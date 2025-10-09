import 'package:flutter/material.dart';
import 'package:flutter_application_landing_page/widgets/custom_text_field_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String? selectedRole;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formkey = GlobalKey<FormState>();
  DateTime? selectedDate;

  void _ShowDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      initialDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate; // Guardar la fecha seleccionada
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xfff4f6f7),
          body: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 1000,
                height: 1500,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      color: Color(0xffffffff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 300),

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,

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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff253f8d),
                                ),
                              ),

                              //Join us
                              Text(
                                'Únete a ProLab UNIMET',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 113, 123, 136),
                                ),
                              ),
                              SizedBox(height: 22, width: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  bool isWide = constraints.maxWidth > 800;

                                  return Form(
                                    key: _formkey,
                                    child: isWide
                                        ? Row(
                                            //
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child:
                                                    //Column 1 - left
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Nombre Completo',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                              0xff707a72,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),

                                                        SizedBox(
                                                          //width: 340,
                                                          height: 41,
                                                          child: CustomTextField(
                                                            labelText:
                                                                ('Nombre'),
                                                            hintText:
                                                                'Jhon Doe',
                                                            iconData: Icons
                                                                .person_2_outlined,
                                                            controller:
                                                                nameController,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .trim()
                                                                      .isEmpty) {
                                                                return 'Por favor, ingresa tu nombre';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 30,
                                                        ),

                                                        Text(
                                                          'Correo Electrónico',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                              0xff707a72,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        SizedBox(
                                                          //width: 340,
                                                          height: 41,
                                                          child: CustomTextField(
                                                            labelText:
                                                                ('Email'),
                                                            hintText:
                                                                'tu@email.com',
                                                            iconData: Icons
                                                                .email_outlined,
                                                            keyboardType:
                                                                TextInputType
                                                                    .emailAddress,
                                                            controller:
                                                                emailController,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Ingresa tu correo electrónico';
                                                              } else if (!RegExp(
                                                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                              ).hasMatch(
                                                                value,
                                                              )) {
                                                                return 'Correo inválido';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 30,
                                                        ),
                                                        Text(
                                                          'Contraseña',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                              0xff707a72,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        SizedBox(
                                                          height: 41,
                                                          child: CustomTextField(
                                                            labelText:
                                                                ('Contraseña'),
                                                            hintText:
                                                                '••••••••',
                                                            iconData: Icons
                                                                .lock_outline,
                                                            obscureText: true,
                                                            controller:
                                                                passwordController,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Ingresa una contraseña';
                                                              } else if (value
                                                                      .length <
                                                                  6) {
                                                                return 'Debe tener al menos 6 caracteres';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 30,
                                                        ),

                                                        Text(
                                                          'Confirmar Contraseña',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                              0xff707a72,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        SizedBox(
                                                          height: 41,
                                                          child: CustomTextField(
                                                            labelText:
                                                                ('Confirmar Contraseña'),
                                                            hintText:
                                                                'Repite tu contraseña',
                                                            iconData: Icons
                                                                .lock_outline,
                                                            obscureText: true,
                                                            controller:
                                                                confirmPasswordController,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Repite la contraseña';
                                                              } else if (value !=
                                                                  passwordController
                                                                      .text) {
                                                                return 'Las contraseñas no coinciden';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              ),

                                              SizedBox(width: 20),

                                              //Column 2 - right
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Teléfono',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color(
                                                          0xff707a72,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    SizedBox(
                                                      height: 41,
                                                      child: CustomTextField(
                                                        labelText: ('Teléfono'),
                                                        hintText:
                                                            '0414 1234567',
                                                        iconData: Icons
                                                            .phone_android_outlined,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Ingresa tu número de teléfono';
                                                          } else if (!RegExp(
                                                            r'^\d{7,11}$',
                                                          ).hasMatch(value)) {
                                                            return 'Número inválido';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    Text(
                                                      'Tipo de Usuario',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color(
                                                          0xff707a72,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    SizedBox(
                                                      height: 41,
                                                      child: DropdownButtonFormField<String>(
                                                        decoration: InputDecoration(
                                                          prefixIcon: Icon(
                                                            Icons
                                                                .person_4_outlined,
                                                          ),
                                                          hintText:
                                                              'Selecciona un rol',
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xffc3e7db,
                                                                  ),
                                                                  width: 1.3,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        164,
                                                                        205,
                                                                        191,
                                                                      ),
                                                                  width: 1.5,
                                                                ),
                                                          ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 1.5,
                                                                ),
                                                          ),
                                                        ),
                                                        items: const [
                                                          DropdownMenuItem(
                                                            value:
                                                                'Coordinador',
                                                            child: Text(
                                                              'Coordinador',
                                                            ),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'Usuario',
                                                            child: Text(
                                                              'Usuario',
                                                            ),
                                                          ),
                                                        ],
                                                        initialValue:
                                                            selectedRole,
                                                        validator: (value) =>
                                                            value == null
                                                            ? 'Selecciona un tipo de usuario'
                                                            : null,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedRole =
                                                                value; // Mantiene el valor seleccionado
                                                          });
                                                        },
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    Text(
                                                      'Cédula',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color(
                                                          0xff707a72,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    SizedBox(
                                                      height: 41,
                                                      child: CustomTextField(
                                                        labelText: 'Cédula',
                                                        hintText:
                                                            'Número de cédula',
                                                        iconData: Icons
                                                            .assignment_ind_outlined,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Ingresa tu cédula';
                                                          } else if (!RegExp(
                                                            r'^\d{7,8}$',
                                                          ).hasMatch(value)) {
                                                            return 'Ingrese correctamente su cédula ';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 30),

                                                    Text(
                                                      'Fecha de Nacimiento',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color(
                                                          0xff707a72,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    SizedBox(
                                                      height: 41,
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        onTap: _ShowDatePicker,
                                                        decoration: InputDecoration(
                                                          hintText:
                                                              'dd/mm/yyyy',
                                                          prefixIcon: const Icon(
                                                            Icons
                                                                .calendar_today_outlined,
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xffc3e7db,
                                                                  ),
                                                                  width: 1.3,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        164,
                                                                        205,
                                                                        191,
                                                                      ),
                                                                  width: 1.5,
                                                                ),
                                                          ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 1.5,
                                                                ),
                                                          ),
                                                        ),
                                                        controller:
                                                            TextEditingController(
                                                              text:
                                                                  selectedDate ==
                                                                      null
                                                                  ? ''
                                                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                                            ),
                                                        validator: (value) {
                                                          if (selectedDate ==
                                                              null) {
                                                            return 'Selecciona una fecha';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nombre Completo',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              CustomTextField(
                                                labelText: 'Nombre',
                                                hintText: 'Jhon Doe',
                                                iconData: Icons.person_outline,
                                                controller: nameController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Por favor, ingresa tu nombre';
                                                  }
                                                  return null;
                                                },
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Correo Electrónico',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              CustomTextField(
                                                labelText: 'Correo',
                                                hintText: 'tucorreo@email.com',
                                                iconData: Icons.email_outlined,
                                                controller: emailController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Ingresa tu correo electrónico';
                                                  } else if (!RegExp(
                                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                  ).hasMatch(value)) {
                                                    return 'Correo inválido';
                                                  }
                                                  return null;
                                                },
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Contraseña',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              //SizedBox(width: 320),
                                              SizedBox(
                                                height: 41,
                                                child: CustomTextField(
                                                  labelText: ('Contraseña'),
                                                  hintText: '••••••••',
                                                  iconData: Icons.lock_outline,
                                                  obscureText: true,
                                                  controller:
                                                      passwordController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Ingresa una contraseña';
                                                    } else if (value.length <
                                                        6) {
                                                      return 'Debe tener al menos 6 caracteres';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Confirmar Contraseña',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              //SizedBox(width: 320),
                                              SizedBox(
                                                height: 41,
                                                child: CustomTextField(
                                                  labelText:
                                                      ('Confirmar Contraseña'),
                                                  hintText:
                                                      'Repite tu contraseña',
                                                  iconData: Icons.lock_outline,
                                                  obscureText: true,
                                                  controller:
                                                      confirmPasswordController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Repite la contraseña';
                                                    } else if (value !=
                                                        passwordController
                                                            .text) {
                                                      return 'Las contraseñas no coinciden';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Teléfono',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              CustomTextField(
                                                labelText: 'Teléfono',
                                                hintText: '0414 1234567',
                                                iconData: Icons
                                                    .phone_android_outlined,
                                                controller: phonecontroller,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Ingresa tu número de teléfono';
                                                  } else if (!RegExp(
                                                    r'^\d{7,11}$',
                                                  ).hasMatch(value)) {
                                                    return 'Número inválido';
                                                  }
                                                  return null;
                                                },
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Tipo de Usuario',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                height: 41,
                                                child: DropdownButtonFormField<String>(
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.person_4_outlined,
                                                    ),
                                                    hintText:
                                                        'Selecciona un rol',
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xffc3e7db,
                                                                ),
                                                                width: 1.3,
                                                              ),
                                                        ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  164,
                                                                  205,
                                                                  191,
                                                                ),
                                                            width: 1.5,
                                                          ),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.red,
                                                            width: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'Coordinador',
                                                      child: Text(
                                                        'Coordinador',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'Usuario',
                                                      child: Text('Usuario'),
                                                    ),
                                                  ],
                                                  initialValue: selectedRole,
                                                  validator: (value) =>
                                                      value == null
                                                      ? 'Selecciona un tipo de usuario'
                                                      : null,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedRole =
                                                          value; // Mantiene el valor seleccionado
                                                    });
                                                  },
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Cédula',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                height: 41,
                                                child: CustomTextField(
                                                  labelText: 'Cédula',
                                                  hintText: 'Número de cédula',
                                                  iconData: Icons
                                                      .assignment_ind_outlined,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Ingresa tu cédula';
                                                    } else if (!RegExp(
                                                      r'^\d{7,8}$',
                                                    ).hasMatch(value)) {
                                                      return 'Ingrese correctamente su cédula ';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                'Fecha de Nacimiento',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff707a72),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                height: 41,
                                                child: TextFormField(
                                                  readOnly: true,
                                                  onTap: _ShowDatePicker,
                                                  decoration: InputDecoration(
                                                    hintText: 'dd/mm/yyyy',
                                                    prefixIcon: const Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xffc3e7db,
                                                                ),
                                                                width: 1.3,
                                                              ),
                                                        ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  164,
                                                                  205,
                                                                  191,
                                                                ),
                                                            width: 1.5,
                                                          ),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.red,
                                                            width: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                  controller: TextEditingController(
                                                    text: selectedDate == null
                                                        ? ''
                                                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                                  ),
                                                  validator: (value) {
                                                    if (selectedDate == null) {
                                                      return 'Selecciona una fecha';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                  );
                                },
                              ),
                              const SizedBox(height: 30),

                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return SizedBox(
                                    height: 41,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formkey.currentState!.validate()) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Cuenta creada con éxito',
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xff253f8d,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 35,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(8),
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
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '¿Ya tienes cuenta? Inicia sesión aquí',
                                textAlign: TextAlign.center,
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
        ),
      ],
    );
  }
}
