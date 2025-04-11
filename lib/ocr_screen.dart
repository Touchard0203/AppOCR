import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  File? _image;
  String _extractedText = 'Texto extraído aparecerá aquí';
  final picker = ImagePicker();

  Future<void> _takePicture() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _performOCR();
    }
  }

  Future<void> _performOCR() async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(_image!.path);
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognizedText.text;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reconocimiento OCR'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _takePicture,
                  child: Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_image!, height: 200, fit: BoxFit.cover),
                  ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: _extractedText),
                    maxLines: null, // Allows multiple lines
                    decoration: InputDecoration(
                      hintText: 'Texto extraído aparecerá aquí...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16),
                    readOnly: true, // Makes the text field read-only
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
