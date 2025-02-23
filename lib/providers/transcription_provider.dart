import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/transcription.dart';

class TranscriptionProvider with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isRecording = false;
  String _currentText = '';
  final List<Transcription> _transcriptions = [];

  bool get isRecording => _isRecording;
  String get currentText => _currentText;
  List<Transcription> get transcriptions => List.unmodifiable(_transcriptions);

  Future<void> startRecording() async {
    if (!_isRecording) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) => debugPrint('Status: $status'),
          onError: (error) => debugPrint('Error: $error'),
        );

        if (available) {
          await _speech.listen(
            onResult: (result) {
              _currentText = result.recognizedWords;
              notifyListeners();
            },
            listenFor: const Duration(seconds: 300),
            partialResults: true,
            cancelOnError: true,
            listenMode: ListenMode.dictation,
          );
          _isRecording = true;
          notifyListeners();
        } else {
          debugPrint('El reconocimiento de voz no está disponible');
        }
      } catch (e) {
        debugPrint('Error al iniciar la grabación: $e');
        _isRecording = false;
        notifyListeners();
      }
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _speech.stop();
      _isRecording = false;
      
      if (_currentText.isNotEmpty) {
        _transcriptions.insert(
          0,
          Transcription(
            text: _currentText,
            dateTime: DateTime.now(),
          ),
        );
        _currentText = '';
      }
      
      notifyListeners();
    }
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'No se pudo acceder al micrófono. Por favor, verifica que la aplicación '
            'tenga los permisos necesarios en la configuración de tu dispositivo.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

