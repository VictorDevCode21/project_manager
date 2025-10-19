import 'package:flutter/material.dart';
import 'package:prolab_unimet/views/layouts/admin_layout.dart';
import 'package:prolab_unimet/widgets/custom_text_field_widget.dart';
import 'package:prolab_unimet/controllers/register_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.arrow_back, color: Colors.black),
            label: Text(
              'Volver al dashboard',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
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

class ProfileManager extends StatefulWidget {
  const ProfileManager({super.key});

  @override
  State<ProfileManager> createState() => _ProfileManagerState();
}

class _ProfileManagerState extends State<ProfileManager> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 900,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_2_outlined, color: Colors.indigo),
                Text(
                  'Informacion personal',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Actualiza tu información personal y datos de contacto'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.account_circle),
                  color: Colors.indigo,
                  iconSize: 80,
                ),
              ],
            ),
            Form(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: column1()),
                  SizedBox(width: 30),
                  Expanded(child: column2()),
                ],
              ),
            ),
            descriptionBox(),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [cancel1(), SizedBox(width: 10), saveChanges()],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget column1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nombre completo'),
        CustomTextField(
          labelText: 'nombre',
          hintText: 'Tu nombre completo',
          iconData: Icons.person,
        ),
        SizedBox(height: 10),
        Text('Correo electronico'),
        CustomTextField(
          labelText: 'correo',
          hintText: 'tu@email.com',
          iconData: Icons.mail,
        ),
        SizedBox(height: 10),
        Text('Telefono'),
        CustomTextField(
          labelText: 'telefono',
          hintText: '+58 123 456 789',
          iconData: Icons.phone,
        ),
      ],
    );
  }

  Widget column2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contraseña'),
        CustomTextField(
          labelText: 'nombre',
          hintText: '123456789',
          iconData: Icons.password,
        ),
        SizedBox(height: 10),
        Text('Cedula'),
        CustomTextField(
          labelText: 'cedula',
          hintText: 'Numero de cedula',
          iconData: Icons.info,
        ),
        SizedBox(height: 10),
        Text('Fecha de nacimiento'),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(1950),
              initialDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
          },
        ),
      ],
    );
  }

  Widget descriptionBox() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.cyan)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Descripcion personal'), TextField()],
      ),
    );
  }

  Widget cancel1() {
    return OutlinedButton(onPressed: () {}, child: Text('Cancelar'));
  }

  Widget saveChanges() {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(Icons.save, color: Colors.white),
      label: Text(
        'Guardar cambios',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
