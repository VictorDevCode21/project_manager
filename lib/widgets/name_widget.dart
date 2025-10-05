import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person_2_outlined),
          hintText: 'Jhon Doe',
        ),
      ),
      // decoration: InputDecoration(
      //   labelText: labelText,
      //   hintText: hintText,
      //   border: OutlineInputBorder(),
      // ),
    );
  }
}
