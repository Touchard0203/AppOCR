import 'package:flutter/material.dart';
import '../login_page.dart';
import 'documentos_page_user.dart';

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
    String usuarioDetails = '¡Hola ${usuario["nombre_usuario"]}!\n\n';
    usuarioDetails += 'Tu información de usuario es:\n\n';

    usuario.forEach((key, value) {
      String formattedKey = key.replaceAll('_', ' ').splitMapJoin(
            RegExp(r'\b\w'),
            onMatch: (m) => m.group(0)!.toUpperCase(),
            onNonMatch: (n) => n,
          );
      usuarioDetails += '${formattedKey}: $value\n';
    });

    String? idDependencia;
    String? idUsuario;

    if (usuario.containsKey('id_dependencia')) {
      idDependencia = usuario['id_dependencia'].toString();
      print('DEBUG: El id_dependencia del usuario es: $idDependencia');
    } else {
      print(
          'DEBUG: La clave "id_dependencia" no se encontró en los datos del usuario.');
    }

    if (usuario.containsKey('id_usuario')) {
      idUsuario = usuario['id_usuario'].toString();
      print('DEBUG: El id_usuario del usuario es: $idUsuario');
    } else {
      idUsuario = usuario['nombre_usuario']?.toString();
      print(
          'DEBUG: La clave "id_usuario" no se encontró, usando nombre_usuario como id: $idUsuario');
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                        builder: (context) => DocumentosPageUser(
                          idDependencia: idDependencia!,
                          idUsuario: idUsuario!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Faltan datos de dependencia o usuario para ver documentos.')),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Funcionalidad de usuario próximamente...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Explorar Opciones',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
