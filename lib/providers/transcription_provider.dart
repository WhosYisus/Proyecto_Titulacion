import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/transcription.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';


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
          title: "Grabación ${_transcriptions.length + 1}",
          text: _currentText,
          dateTime: DateTime.now(),
        ),
      );
      _currentText = '';
      await saveTranscriptions(); // 🔹 Guarda en Hive después de grabar
    }

    notifyListeners();
  }
}



  Future<void> loadTranscriptions() async {
  var box = Hive.box('transcriptions');
  List<dynamic>? transcriptionsData = box.get("transcriptions");

  if (transcriptionsData != null) {
    _transcriptions.clear(); // 🔹 Limpiar la lista antes de cargar datos
    for (var data in transcriptionsData) {
      _transcriptions.add(Transcription(
        title: data["title"], // 🔹 Asegurar que el título se carga correctamente
        text: data["text"],
        dateTime: DateTime.parse(data["dateTime"]),
      ));
    }
    notifyListeners();
   }
  }

 TranscriptionProvider() {
  loadTranscriptions();
  }

  Future<void> saveTranscriptions() async {
  var box = Hive.box('transcriptions');
  await box.put("transcriptions", _transcriptions.map((t) => {
    "title": t.title, // 🔹 Asegurar que se guarda el título correcto
    "text": t.text,
    "dateTime": t.dateTime.toIso8601String(),
  }).toList());
  }


  void deleteTranscription(int index) {
  if (index >= 0 && index < _transcriptions.length) {
    _transcriptions.removeAt(index);
    saveTranscriptions(); // 🔹 Actualiza Hive después de eliminar
    notifyListeners();
  }
  }


  void updateTitle(int index, String newTitle) {
  if (index >= 0 && index < _transcriptions.length) {
    _transcriptions[index] = Transcription(
      title: newTitle, // 🔹 Guardar el nuevo nombre
      text: _transcriptions[index].text,
      dateTime: _transcriptions[index].dateTime,
    );
    saveTranscriptions(); // 🔹 Guardar en Hive después de cambiar el título
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

