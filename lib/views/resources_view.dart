import 'package:flutter/material.dart';

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResourcesBar(),
        SizedBox(height: 30),
        Stats(),
        SizedBox(height: 30),
        SearchBar1(),
      ],
    );
  }
}

class ResourcesBar extends StatelessWidget {
  const ResourcesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.arrow_back, color: Colors.black),
          label: Text(
            'Volver',
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Recursos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text('Administrar recursos humanos y materiales'),
          ],
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.person_add, color: Colors.black),
          label: Text(
            'Asignar recursos',
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
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.plus_one, color: Colors.white),
          label: Text(
            'Agregar recursos',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }
}

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          shadowColor: Colors.black,
          child: Column(
            children: [
              Text('Personal disponible'),
              SizedBox(height: 40),
              Text('X'),
              Text('de Y total'),
            ],
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          shadowColor: Colors.black,
          child: Column(
            children: [
              Text('Equipos disponibles'),
              SizedBox(height: 40),
              Text('X'),
              Text('de Y total'),
            ],
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          shadowColor: Colors.black,
          child: Column(
            children: [
              Text('Utilizacion promedio'),
              SizedBox(height: 40),
              Text('X%'),
              Text('capacidad utilizada'),
            ],
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          shadowColor: Colors.black,
          child: Column(
            children: [
              Text('En mantenimiento'),
              SizedBox(height: 40),
              Text('X'),
              Text('equipos en servicio'),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchBar1 extends StatefulWidget {
  const SearchBar1({super.key});

  @override
  State<SearchBar1> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1100,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros y Búsqueda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                items:
                    [
                          'Todos los estados',
                          'Disponible',
                          'Ocupado',
                          'En Uso',
                          'Parcialmente Disponible',
                          'Mantenimiento',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
