import 'package:flutter/material.dart';
import '../login_page.dart'; // Asegúrate de que esta ruta sea correcta
import 'documentos_page_user.dart'; // Importa la nueva página de documentos

class UsuarioPage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const UsuarioPage({Key? key, required this.usuario}) : super(key: key);

  void _logout(BuildContext context) {
    // Al cerrar sesión, reemplazamos la ruta para que el usuario no pueda volver atrás
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construye una cadena de texto con todos los atributos del usuario
    String usuarioDetails = '¡Hola ${usuario["nombre_usuario"]}!\n\n';
    usuarioDetails += 'Tu información de usuario es:\n\n';

    // Itera sobre todas las entradas en el mapa 'usuario' y las añade a la cadena
    usuario.forEach((key, value) {
      // Formatea la clave para que sea más legible (ej. "nombre_usuario" -> "Nombre Usuario")
      String formattedKey = key.replaceAll('_', ' ').splitMapJoin(
            RegExp(r'\b\w'),
            onMatch: (m) => m.group(0)!.toUpperCase(),
            onNonMatch: (n) => n,
          );
      usuarioDetails += '${formattedKey}: $value\n';
    });

    // --- CÓDIGO PARA OBTENER Y MOSTRAR id_dependencia (para depuración) ---
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
      // Asumiendo que tu backend devuelve un 'id_usuario'
      idUsuario = usuario['id_usuario'].toString();
      print('DEBUG: El id_usuario del usuario es: $idUsuario');
    } else {
      // Si no hay 'id_usuario', puedes usar 'nombre_usuario' o manejarlo según tu lógica
      idUsuario = usuario['nombre_usuario']
          ?.toString(); // Usa nombre_usuario como fallback o ajusta
      print(
          'DEBUG: La clave "id_usuario" no se encontró, usando nombre_usuario como id: $idUsuario');
    }
    // -------------------------------------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEMAPA SISTEMA DOCUMENTOS'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white, // Color del texto del título
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip:
                'Cerrar sesión', // Texto que aparece al mantener presionado
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          // Permite hacer scroll si el contenido es largo
          padding: const EdgeInsets.all(
              20.0), // Añade un padding para mejor legibilidad
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea el texto a la izquierda
            children: [
              Text(
                usuarioDetails,
                textAlign: TextAlign.left, // Alinea el texto a la izquierda
                style: const TextStyle(
                    fontSize: 18.0,
                    height: 1.5), // Ajusta tamaño y espaciado de línea
              ),
              const SizedBox(height: 30),
              // Botón para navegar a la página de documentos
              ElevatedButton(
                onPressed: () {
                  // Asegúrate de que idDependencia y idUsuario no sean nulos antes de navegar
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
              const SizedBox(height: 10), // Espacio entre botones
              ElevatedButton(
                onPressed: () {
                  // Ejemplo: Navegar a otra sección específica de usuario
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
