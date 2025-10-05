import 'package:flutter/material.dart';

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
                    margin: EdgeInsets.all(16),
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
                                Image.asset(
                                  'assets/images/ProlabIcon.png',
                                  width: 100,
                                  height: 100,
                                ),

                                SizedBox(height: 10),

                                Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff253f8d),
                                  ),
                                ),
                                Text(
                                  'Únete a ProLab UNIMET',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 113, 123, 136),
                                  ),
                                ),
                                SizedBox(height: 60, width: 40),

                                SizedBox(
                                  width: 700,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Nombre Completo'),
                                      Text('Teléfono'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),

                                SizedBox(
                                  width: 700,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                ),
                                SizedBox(
                                  width: 700,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 320,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Ej. Jhon Doe',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 700,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 320,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Ej. 0414 1234567',
                                            border: OutlineInputBorder(),
                                          ),
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
