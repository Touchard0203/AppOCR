import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../configuracion.dart';

class Carpeta {
  final String idCarpeta;
  final String nombre;
  final String? idPadre;
  final String idDependencia;

  Carpeta({
    required this.idCarpeta,
    required this.nombre,
    this.idPadre,
    required this.idDependencia,
  });

  factory Carpeta.fromJson(Map<String, dynamic> json) {
    return Carpeta(
      idCarpeta: json['id_carpeta'].toString(),
      nombre: json['nombre'],
      idPadre: json['id_padre']?.toString(),
      idDependencia: json['id_dependencia'].toString(),
    );
  }
}

class Documento {
  final String idDocumento;
  final String nombreDocumento;
  final String rutaArchivo;

  Documento(
      {required this.idDocumento,
      required this.nombreDocumento,
      required this.rutaArchivo});

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      idDocumento: json['id_documento'].toString(),
      nombreDocumento: json['nombre_documento'],
      rutaArchivo: json['ruta_archivo'],
    );
  }
}

class DocumentosPageAdmin extends StatefulWidget {
  final String idDependencia;
  final String idUsuario;

  const DocumentosPageAdmin({
    super.key,
    required this.idDependencia,
    required this.idUsuario,
  });

  @override
  State<DocumentosPageAdmin> createState() => _DocumentosPageAdminState();
}

class _DocumentosPageAdminState extends State<DocumentosPageAdmin> {
  List<Carpeta> carpetas = [];
  List<Documento> documentos = [];
  List<String> path = [];
  String? currentFolder;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await fetchCarpetas();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchCarpetas() async {
    try {
      final url = '${Config.ipback}/carpetas';
      print('DEBUG (User): Solicitando TODAS las carpetas (global): $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> carpetasJson = data['carpetas'];
        setState(() {
          carpetas = carpetasJson.map((e) => Carpeta.fromJson(e)).toList();
          print('DEBUG (User): Carpetas cargadas: ${carpetas.length}');
        });
      } else {
        print(
            'Error al cargar las carpetas (User): ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error al cargar las carpetas: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Excepción al cargar las carpetas (User): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('No se pudo conectar al servidor para las carpetas: $e')),
      );
    }
  }

  Future<void> fetchDocumentos(String idCarpeta) async {
    setState(() {
      _isLoading = true;
      documentos = [];
    });
    try {
      final url =
          '${Config.ipback}/documentos/?id_carpeta=$idCarpeta&id_dependencia=${widget.idDependencia}';
      print('DEBUG (User): Solicitando documentos de: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docsJson = data['documentos'];
        setState(() {
          documentos = docsJson.map((e) => Documento.fromJson(e)).toList();
          print('DEBUG (User): Documentos cargados: ${documentos.length}');
        });
      } else {
        print(
            'Error al cargar los documentos (User): ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al cargar los documentos: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Excepción al cargar los documentos (User): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'No se pudo conectar al servidor para los documentos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> registrarUsoDocumento(String idDocumento) async {
    try {
      await http.put(Uri.parse('${Config.ipback}/documentos/uso/$idDocumento'));
    } catch (e) {
      print('Error al registrar uso del documento: $e');
    }
  }

  Future<void> registrarUsoCarpeta(String idCarpeta) async {
    try {
      await http.put(Uri.parse('${Config.ipback}/carpetas/uso/$idCarpeta'));
    } catch (e) {
      print('Error al registrar uso de la carpeta: $e');
    }
  }

  void abrirCarpeta(String idCarpeta) {
    setState(() {
      currentFolder = idCarpeta;
      path.add(idCarpeta);
      documentos = [];
    });
    registrarUsoCarpeta(idCarpeta);
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
      } else {
        _loadInitialData();
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el documento: $url')),
      );
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
        foregroundColor: Colors.white,
        leading: path.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: retroceder,
                tooltip: 'Retroceder',
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : carpetasFiltradas.isEmpty && documentos.isEmpty
                ? const Center(
                    child: Text("Sin contenido en esta carpeta o dependencia."))
                : Column(
                    children: [
                      // Sección de Carpetas
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
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              final carpeta = carpetasFiltradas[index];
                              return GestureDetector(
                                onTap: () => abrirCarpeta(carpeta.idCarpeta),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.folder,
                                          size: 50, color: Colors.orange),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          carpeta.nombre,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      // Separador si hay carpetas y documentos
                      if (carpetasFiltradas.isNotEmpty && documentos.isNotEmpty)
                        const Divider(
                            height: 20,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10),

                      // Sección de Documentos
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
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              final doc = documentos[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.insert_drive_file,
                                        size: 50, color: Colors.blue),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        doc.nombreDocumento,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        registrarUsoDocumento(doc.idDocumento);
                                        _launchURL(
                                            '${Config.solIP}/${doc.rutaArchivo}');
                                      },
                                      child: const Text("Ver",
                                          style:
                                              TextStyle(color: Colors.indigo)),
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
