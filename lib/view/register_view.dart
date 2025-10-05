import 'package:flutter/material.dart';
import 'package:web_project_manager/widgets/customTextField_Widget.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

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
              //height: 700,
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    margin: EdgeInsets.all(10),
                    color: Color(0xffffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 300),

                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 115),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                //Logo
                                Image.asset(
                                  'assets/images/ProlabIcon.png',
                                  width: 100,
                                  height: 100,
                                ),

                                SizedBox(height: 10),

                                //Crear Cuenta
                                Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff253f8d),
                                  ),
                                ),

                                //Unete
                                Text(
                                  'Únete a ProLab UNIMET',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 113, 123, 136),
                                  ),
                                ),
                                SizedBox(height: 60, width: 40),

                                //Campos
                                SizedBox(
                                  width: 700,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Column 1
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Nombre Completo'),
                                          const SizedBox(height: 10),

                                          SizedBox(
                                            width: 320,
                                            height: 40,
                                            child: CustomTextField(
                                              labelText: ('Nombre'),
                                              hintText: 'Jhon Doe',
                                              iconData: Icons.person_2_outlined,
                                            ),
                                          ),
                                          const SizedBox(height: 30),

                                          Text('Correo Electrónico'),
                                          const SizedBox(height: 10),
                                          SizedBox(width: 320),
                                          SizedBox(
                                            width: 320,
                                            height: 40,
                                            child: CustomTextField(
                                              labelText: ('Email'),
                                              hintText: 'tu@email.com',
                                              iconData: Icons.email_outlined,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                            ),
                                          ),
                                        ],
                                      ),

                                      //Column 2
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Teléfono'),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: 320,
                                            height: 40,
                                            child: CustomTextField(
                                              labelText: ('Teléfono'),
                                              hintText: '0414 1234567',
                                              iconData:
                                                  Icons.phone_android_outlined,
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          Text('Teléfono'),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: 320,
                                            height: 40,
                                            child: CustomTextField(
                                              labelText: ('Teléfono'),
                                              hintText: '0414 1234567',
                                              iconData:
                                                  Icons.phone_android_outlined,
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                        ],
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
