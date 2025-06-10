import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Superadmin/editar_usuario_page.dart';
import 'dart:convert';
import '../configuracion.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<dynamic> usuarios = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse('${Config.ipback}/usuarios'));

      if (response.statusCode == 200) {
        setState(() {
          usuarios = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al obtener los usuarios: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al conectar con el servidor';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(usuario['nombre_usuario']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rol: ${usuario['rol']}'),
                            Text(
                                'Dependencia: ${usuario['id_dependencia'] ?? 'Sin asignar'}'),
                          ],
                        ),
                        leading: CircleAvatar(
                          child:
                              Text(usuario['nombre_usuario'][0].toUpperCase()),
                        ),
                        onTap: () async {
                          final actualizado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditarUsuarioPage(usuario: usuario),
                            ),
                          );

                          if (actualizado == true) {
                            _fetchUsuarios();
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add),
        onPressed: () async {
          final creado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditarUsuarioPage(usuario: null),
            ),
          );

          if (creado == true) {
            _fetchUsuarios();
          }
        },
      ),
    );
  }
}
