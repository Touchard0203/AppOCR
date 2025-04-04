import 'package:flutter/material.dart';
import 'login_page.dart';

class UsuarioPage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const UsuarioPage({Key? key, required this.usuario}) : super(key: key);

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SEMAPA SISTEMA DOCUMENTOS'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Hola ${usuario["nombre_usuario"]}, eres un Usuario.'),
      ),
    );
  }
}
