import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../configuracion.dart'; // Archivo con la configuración de la IP

// Modelo para las carpetas
class Carpeta {
  final String idCarpeta;
  final String nombre;
  final String? idPadre;
  final String
      idDependencia; // ¡Importante! Añadido para filtrar por dependencia

  Carpeta({
    required this.idCarpeta,
    required this.nombre,
    this.idPadre,
    required this.idDependencia, // Hacerlo requerido en el constructor
  });

  factory Carpeta.fromJson(Map<String, dynamic> json) {
    return Carpeta(
      idCarpeta: json['id_carpeta'].toString(),
      nombre: json['nombre'],
      idPadre: json['id_padre']?.toString(),
      idDependencia: json['id_dependencia']
          .toString(), // Asegúrate de que este campo exista en tu JSON de carpetas
    );
  }
}

// Modelo para los documentos
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

class DocumentosPageUser extends StatefulWidget {
  final String idDependencia; // Recibimos el ID de la dependencia del usuario
  final String idUsuario; // Recibimos el ID del usuario

  const DocumentosPageUser({
    super.key,
    required this.idDependencia,
    required this.idUsuario,
  });

  @override
  State<DocumentosPageUser> createState() => _DocumentosPageUserState();
}

class _DocumentosPageUserState extends State<DocumentosPageUser> {
  List<Carpeta> carpetas = [];
  List<Documento> documentos = [];
  List<String> path = []; // Pila de navegación para las carpetas
  String? currentFolder; // ID de la carpeta actual

  bool _isLoading = true; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Carga las carpetas iniciales (raíz de la dependencia del usuario)
  }

  // Función para cargar datos iniciales (carpetas de la dependencia del usuario)
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await fetchCarpetas(); // Carga todas las carpetas (globales)
    setState(() {
      _isLoading = false;
    });
  }

  // Obtiene TODAS las carpetas (globales), sin filtro por id_dependencia en la URL
  Future<void> fetchCarpetas() async {
    try {
      // Si las carpetas son globales, no se filtra por id_dependencia en la URL
      final url = '${Config.ipback}/carpetas';
      print(
          'DEBUG (User): Solicitando TODAS las carpetas (global): $url'); // Para depuración
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> carpetasJson = data['carpetas'];
        setState(() {
          // Mapeamos todas las carpetas. El filtro por idPadre se aplica en el build.
          // No aplicamos filtro por idDependencia aquí, ya que las carpetas son globales.
          carpetas = carpetasJson.map((e) => Carpeta.fromJson(e)).toList();
          print(
              'DEBUG (User): Carpetas cargadas: ${carpetas.length}'); // Para depuración
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

  // Obtiene los documentos filtrados por id_carpeta, id_dependencia y id_usuario
  Future<void> fetchDocumentos(String idCarpeta) async {
    setState(() {
      _isLoading = true;
      documentos = []; // Limpia los documentos anteriores
    });
    try {
      // Construye la URL con todos los parámetros de filtrado para el endpoint /documentos/docs/
      final url =
          '${Config.ipback}/documentos/docs/?id_carpeta=$idCarpeta&id_dependencia=${widget.idDependencia}&id_usuario=${widget.idUsuario}';
      print('DEBUG (User): Solicitando documentos de: $url'); // Para depuración
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docsJson = data['documentos'];
        setState(() {
          documentos = docsJson.map((e) => Documento.fromJson(e)).toList();
          print(
              'DEBUG (User): Documentos cargados: ${documentos.length}'); // Para depuración
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

  // Abre una carpeta y carga sus documentos
  void abrirCarpeta(String idCarpeta) {
    setState(() {
      currentFolder = idCarpeta;
      path.add(idCarpeta);
      documentos = []; // Limpiamos los documentos al cambiar de carpeta
    });
    fetchDocumentos(idCarpeta);
  }

  // Retrocede a la carpeta padre
  void retroceder() {
    if (path.isNotEmpty) {
      path.removeLast();
      final anterior = path.isNotEmpty ? path.last : null;
      setState(() {
        currentFolder = anterior;
        documentos = []; // Limpiamos documentos al retroceder
      });
      if (anterior != null) {
        fetchDocumentos(anterior);
      } else {
        // Si retrocedemos a la raíz (currentFolder es null), volvemos a cargar las carpetas principales (globales)
        _loadInitialData();
      }
    }
  }

  // Abre un documento en el navegador
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
    // Filtra las carpetas para mostrar solo las que están en la carpeta actual
    // (idPadre coincide con currentFolder).
    // Las carpetas ya fueron cargadas globalmente en fetchCarpetas.
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
            ? const Center(
                child: CircularProgressIndicator()) // Indicador de carga
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
                              childAspectRatio:
                                  1.0, // Para que las tarjetas sean cuadradas
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
                                          maxLines: 2, // Limita a 2 líneas
                                          overflow: TextOverflow
                                              .ellipsis, // Añade puntos suspensivos si el texto es muy largo
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
                              childAspectRatio:
                                  1.0, // Para que las tarjetas sean cuadradas
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
