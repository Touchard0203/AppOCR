import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configuracion.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Map? usuario;

  const EditarUsuarioPage({super.key, this.usuario});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  late TextEditingController nombreController;
  late TextEditingController contrasenaController;
  late TextEditingController rolController;
  late TextEditingController dependenciaController;

  List<String> rolesPermitidos = ['Usuario', 'Super Admin', 'Admin'];
  List<Map<String, dynamic>> dependencias = [];

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(
        text: widget.usuario != null ? widget.usuario!['nombre_usuario'] : '');
    contrasenaController = TextEditingController(
        text: widget.usuario != null ? widget.usuario!['contraseña'] : '');
    rolController = TextEditingController(
        text: widget.usuario != null ? widget.usuario!['rol'] : '');
    dependenciaController = TextEditingController(
        text:
            widget.usuario != null && widget.usuario!['id_dependencia'] != null
                ? widget.usuario!['id_dependencia'].toString()
                : '');
    _fetchDependencias();
  }

  // Cargar dependencias
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

  Future<void> _guardarUsuario() async {
    final esEdicion = widget.usuario != null;

    if (!rolesPermitidos.contains(rolController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'El rol ingresado no es válido. Elija entre Usuario, Super Admin o Admin')),
      );
      return;
    }

    final url = esEdicion
        ? Uri.parse(
            '${Config.ipback}/usuarios/modificar/${widget.usuario!['id_usuario']}')
        : Uri.parse('${Config.ipback}/usuarios/registrar');

    final data = {
      'nombre_usuario': nombreController.text,
      'contraseña': contrasenaController.text,
      'rol': rolController.text,
      'id_dependencia': dependenciaController.text.isNotEmpty
          ? int.tryParse(dependenciaController.text)
          : null,
    };

    final response = esEdicion
        ? await http.put(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data))
        : await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.usuario != null ? 'Editar Usuario' : 'Agregar Usuario'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: rolController.text.isEmpty ? null : rolController.text,
              decoration: InputDecoration(labelText: 'Rol'),
              items: rolesPermitidos.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  rolController.text = value!;
                });
              },
            ),
            dependencias.isEmpty
                ? CircularProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: dependenciaController.text.isEmpty
                        ? null
                        : int.tryParse(dependenciaController.text),
                    decoration: InputDecoration(labelText: 'Dependencia'),
                    items: dependencias.map((dependencia) {
                      return DropdownMenuItem<int>(
                        value: dependencia['id_dependencia'],
                        child: Text(dependencia['nombre_dependencia']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        dependenciaController.text = value.toString();
                      });
                    },
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarUsuario,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
