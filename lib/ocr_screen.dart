// ocr_screen.dart
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
      appBar: AppBar(title: Text('OCR Flutter App')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _takePicture,
                child: Text('Tomar Foto'),
              ),
              SizedBox(height: 20),
              if (_image != null) Image.file(_image!, height: 200),
              SizedBox(height: 20),
              Text(
                _extractedText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
