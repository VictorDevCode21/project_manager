import 'package:flutter/material.dart';
import 'package:prolab_unimet/views/layouts/admin_layout.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Modificar Perfil',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 28,
              color: Colors.indigo,
              fontWeight: FontWeight.w800,
            ),
          ),

          Text(
            'Actualiza tu información personal y datos de contacto',
            textAlign: TextAlign.left,
          ),
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
            color: Colors.indigo,
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

class ProfileManager extends StatelessWidget {
  const ProfileManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.indigo),
                Text('Informacion personal'),
              ],
            ),
            Row(
              children: [
                Text('Actualiza tu información personal y datos de contacto'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.person),
                  color: Colors.indigo,
                  iconSize: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
