import 'package:flutter/material.dart';
import '../Superadmin/dependencias_page.dart';
import '../Superadmin/documentos_page.dart';
import '../Superadmin/usuarios_page.dart';
import '../login_page.dart';
import '../ocr_screen.dart';

class SuperAdminPage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const SuperAdminPage({Key? key, required this.usuario}) : super(key: key);

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _irAOcr(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OCRScreen()),
    );
  }

  void _irAUsuarios(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsuariosPage()),
    );
  }

  void _irADependencias(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DependenciasPage()),
    );
  }

  void _irACarpetas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentosPage()),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hola ${usuario["nombre_usuario"]}, eres un Super Admin.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _irAOcr(context),
                child: Text('Escanear documento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250, 50),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _irAUsuarios(context),
                child: Text('Usuarios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250, 50),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _irADependencias(context),
                child: Text('Dependencias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250, 50),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _irACarpetas(context),
                child: Text('Carpetas y documentos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
