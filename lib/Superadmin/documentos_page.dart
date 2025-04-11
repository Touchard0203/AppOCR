import 'package:flutter/material.dart';

class DocumentosPage extends StatelessWidget {
  const DocumentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpetas y documentos'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text(
          'Cargar documentos',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
