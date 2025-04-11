import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configuracion.dart';

class DependenciasPage extends StatefulWidget {
  const DependenciasPage({super.key});

  @override
  _DependenciasPageState createState() => _DependenciasPageState();
}

class _DependenciasPageState extends State<DependenciasPage> {
  List<Map<String, dynamic>> dependencias = [];

  @override
  void initState() {
    super.initState();
    _fetchDependencias();
  }

  // Cargar dependencias desde la API
  Future<void> _fetchDependencias() async {
    final response = await http.get(Uri.parse('${Config.ipback}/dependencias'));

    if (response.statusCode == 200) {
      setState(() {
        dependencias =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las dependencias')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Dependencias'),
        backgroundColor: Colors.teal,
      ),
      body: dependencias.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dependencias.length,
              itemBuilder: (context, index) {
                final dependencia = dependencias[index];
                return ListTile(
                  title: Text(dependencia['nombre_dependencia']),
                );
              },
            ),
    );
  }
}
