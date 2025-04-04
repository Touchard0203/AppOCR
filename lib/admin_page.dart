import 'package:flutter/material.dart';
import 'login_page.dart';
import 'ocr_screen.dart';

class AdminPage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const AdminPage({Key? key, required this.usuario}) : super(key: key);

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hola ${usuario["nombre_usuario"]}, eres un Admin.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _irAOcr(context),
              child: Text('Escanear documento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
