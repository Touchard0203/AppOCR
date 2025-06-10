import 'package:flutter/material.dart';
import '../login_page.dart';
import '../ocr_screen.dart';
import 'documentos_page_admin.dart';

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
    String usuarioDetails = '¡Hola ${usuario["nombre_usuario"]}!\n\n';
    usuarioDetails += 'Tu información de usuario es:\n\n';

    usuario.forEach((key, value) {
      String formattedKey = key.replaceAll('_', ' ').splitMapJoin(
            RegExp(r'\b\w'),
            onMatch: (m) => m.group(0)!.toUpperCase(),
            onNonMatch: (n) => n,
          );
      usuarioDetails += '$formattedKey: $value\n';
    });

    String? idDependencia;
    String? idUsuario;

    if (usuario.containsKey('id_dependencia')) {
      idDependencia = usuario['id_dependencia'].toString();
      print('DEBUG: id_dependencia: $idDependencia');
    }

    if (usuario.containsKey('id_usuario')) {
      idUsuario = usuario['id_usuario'].toString();
      print('DEBUG: id_usuario: $idUsuario');
    } else {
      idUsuario = usuario['nombre_usuario']?.toString();
      print('DEBUG: Usando nombre_usuario como id_usuario: $idUsuario');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEMAPA SISTEMA DOCUMENTOS'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuarioDetails,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18.0, height: 1.5),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (idDependencia != null && idUsuario != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentosPageAdmin(
                          idUsuario: idUsuario!,
                          idDependencia: idDependencia!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Faltan datos para mostrar los documentos.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ver Documentos',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _irAOcr(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Escanear Documento',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
