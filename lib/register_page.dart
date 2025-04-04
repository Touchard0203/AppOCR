import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  String? _dependenciaSeleccionada;
  List<dynamic> _dependencias = [];
  String mensaje = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDependencias();
  }

  Future<void> _fetchDependencias() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.0.11:4001/api/dependencias/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dependencias = data;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar dependencias';
      });
    }
  }

  Future<void> _registrarUsuario() async {
    if (_usuarioController.text.isEmpty ||
        _pwdController.text.isEmpty ||
        _dependenciaSeleccionada == null) {
      setState(() {
        mensaje = 'Por favor, complete todos los campos.';
      });
      return;
    }

    final data = {
      'nombre_usuario': _usuarioController.text,
      'contraseña': _pwdController.text,
      'rol': 'Usuario',
      'id_dependencia': _dependenciaSeleccionada,
    };

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.11:4001/api/usuarios/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          mensaje = 'Registro exitoso. Redirigiendo...';
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          mensaje = 'Error: ${result['message']}';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              shrinkWrap: true,
              children: [
                if (mensaje.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      mensaje,
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                TextField(
                  controller: _usuarioController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _pwdController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _dependenciaSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Dependencia',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _dependencias
                      .map<DropdownMenuItem<String>>(
                        (dep) => DropdownMenuItem<String>(
                          value: dep['id_dependencia'].toString(),
                          child: Text(dep['nombre_dependencia']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _dependenciaSeleccionada = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _registrarUsuario,
                  child: Text(isLoading ? 'Registrando...' : 'Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
