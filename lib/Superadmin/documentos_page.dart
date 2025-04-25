import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../configuracion.dart';

class Carpeta {
  final String idCarpeta;
  final String nombre;
  final String? idPadre;

  Carpeta({required this.idCarpeta, required this.nombre, this.idPadre});

  factory Carpeta.fromJson(Map<String, dynamic> json) {
    return Carpeta(
      idCarpeta: json['id_carpeta'].toString(),
      nombre: json['nombre'],
      idPadre: json['id_padre']?.toString(),
    );
  }
}

class Documento {
  final String nombreDocumento;
  final String rutaArchivo;

  Documento({required this.nombreDocumento, required this.rutaArchivo});

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      nombreDocumento: json['nombre_documento'],
      rutaArchivo: json['ruta_archivo'],
    );
  }
}

class DocumentosPage extends StatefulWidget {
  const DocumentosPage({super.key});

  @override
  State<DocumentosPage> createState() => _DocumentosPageState();
}

class _DocumentosPageState extends State<DocumentosPage> {
  List<Carpeta> carpetas = [];
  List<Documento> documentos = [];
  List<String> path = []; // pila de navegación
  String? currentFolder;

  @override
  void initState() {
    super.initState();
    fetchCarpetas();
  }

  Future<void> fetchCarpetas() async {
    try {
      final response = await http.get(Uri.parse('${Config.ipback}/carpetas'));
      final data = jsonDecode(response.body);
      final List<dynamic> carpetasJson = data['carpetas'];
      setState(() {
        carpetas = carpetasJson.map((e) => Carpeta.fromJson(e)).toList();
      });
    } catch (e) {
      print('Error al cargar las carpetas: $e');
    }
  }

  Future<void> fetchDocumentos(String idCarpeta) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.ipback}/documentos/?id_carpeta=$idCarpeta'),
      );
      final data = jsonDecode(response.body);
      final List<dynamic> docsJson = data['documentos'];
      setState(() {
        documentos = docsJson.map((e) => Documento.fromJson(e)).toList();
      });
    } catch (e) {
      print('Error al cargar los documentos: $e');
    }
  }

  void abrirCarpeta(String idCarpeta) {
    setState(() {
      currentFolder = idCarpeta;
      path.add(idCarpeta);
      documentos = [];
    });
    fetchDocumentos(idCarpeta);
  }

  void retroceder() {
    if (path.isNotEmpty) {
      path.removeLast();
      final anterior = path.isNotEmpty ? path.last : null;
      setState(() {
        currentFolder = anterior;
        documentos = [];
      });
      if (anterior != null) {
        fetchDocumentos(anterior);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carpetasFiltradas =
        carpetas.where((c) => c.idPadre == currentFolder).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpetas y Documentos'),
        backgroundColor: Colors.indigo,
        leading:
            path.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: retroceder,
                )
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child:
            carpetasFiltradas.isEmpty && documentos.isEmpty
                ? currentFolder == null
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text("Sin contenido"))
                : Column(
                  children: [
                    if (carpetasFiltradas.isNotEmpty)
                      Expanded(
                        flex: 1,
                        child: GridView.builder(
                          itemCount: carpetasFiltradas.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            final carpeta = carpetasFiltradas[index];
                            return GestureDetector(
                              onTap: () => abrirCarpeta(carpeta.idCarpeta),
                              child: Card(
                                elevation: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder,
                                      size: 40,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      carpeta.nombre,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (documentos.isNotEmpty)
                      Expanded(
                        flex: 1,
                        child: GridView.builder(
                          itemCount: documentos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            final doc = documentos[index];
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      doc.nombreDocumento,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      launchUrl(
                                        Uri.parse(
                                          '${Config.solIP}/${doc.rutaArchivo}',
                                        ),
                                      );
                                    },
                                    child: const Text("Ver"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}
