import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Para descarga en Web

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  const AudioRecorderPage({super.key});

  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Presiona el botón y habla";
  List<String> _transcriptions = [];
  int _recordingNumber = 1;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadTranscriptions();
  }

  void _toggleRecording() async {
    if (!_isListening) {
      bool available = await _speech.initialize(debugLogging: true);
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        });
      } else {
        setState(() {
          _text = "El reconocimiento de voz no está disponible.";
        });
      }
    } else {
      setState(() {
        _isListening = false;
        _transcriptions.add("Grabación $_recordingNumber: $_text");
        _recordingNumber++;
      });
      _speech.stop();
      _saveTranscriptions();
      _saveTranscriptionsToFile();
    }
  }

  void _saveTranscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('transcriptions', jsonEncode(_transcriptions));
    prefs.setInt('recordingNumber', _recordingNumber);
  }

  void _saveTranscriptionsToFile() async {
    if (kIsWeb) return; // No guardar en archivo en Web

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/transcriptions.txt');
    await file.writeAsString(_transcriptions.join('\n'));
  }

  void _loadTranscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTranscriptions = prefs.getString('transcriptions');
    final savedNumber = prefs.getInt('recordingNumber') ?? 1;

    if (savedTranscriptions != null) {
      setState(() {
        _transcriptions = List<String>.from(jsonDecode(savedTranscriptions));
        _recordingNumber = savedNumber;
      });
    }
  }

  void _showTranscriptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Transcripciones"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _transcriptions.map((text) => Text(text)).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _downloadTranscriptions,
              child: const Text("Descargar TXT"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _downloadTranscriptions() async {
    if (kIsWeb) {
      // Guardar en Web
      String transcriptionsText = _transcriptions.join('\n');
      final blob = html.Blob([transcriptionsText], 'text/plain');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "transcriptions.txt")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Guardar en Móvil
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/transcriptions.txt');

      if (await file.exists()) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado en: ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el archivo.')),
        );
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabador de Audio'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showTranscriptions,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: _toggleRecording,
          backgroundColor: _isListening ? Colors.red : Colors.blue,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
