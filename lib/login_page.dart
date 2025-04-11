import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'User/usuario_page.dart';
import 'Administrador/admin_page.dart';
import 'Superadmin/super_admin_page.dart';
import 'configuracion.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  String mensaje = '';

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('${Config.ipback}/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre_usuario': _usuarioController.text.trim(),
        'contraseña': _pwdController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['usuario'] != null) {
      final usuario = data['usuario'];
      final rol = usuario['rol'];

      Widget destino;

      switch (rol) {
        case 'Usuario':
          destino = UsuarioPage(usuario: usuario);
          break;
        case 'Admin':
          destino = AdminPage(usuario: usuario);
          break;
        case 'Super Admin':
          destino = SuperAdminPage(usuario: usuario);
          break;
        default:
          setState(() {
            mensaje = 'Rol no reconocido';
          });
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destino),
      );
    } else {
      setState(() {
        mensaje = data['message'] ?? 'Error al iniciar sesión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _login,
                  child: Text('Iniciar sesión'),
                ),
                if (mensaje.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      mensaje,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
