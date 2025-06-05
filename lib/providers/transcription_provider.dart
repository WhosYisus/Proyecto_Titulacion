import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/transcription.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


class TranscriptionProvider with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isRecording = false;
  String _currentText = '';
  final List<Transcription> _transcriptions = [];

  bool _isPaused = false;
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;

  bool _isFirstResultAfterRestart = false;
  String _lastRecognized = '';
  DateTime _lastRecognizedTime = DateTime.now();

  bool get isRecording => _isRecording;
  String get currentText => _currentText;
  List<Transcription> get transcriptions => List.unmodifiable(_transcriptions);

  bool get isPaused => _isPaused;
  Duration get recordingDuration => _recordingDuration;



  TranscriptionProvider() {
    loadTranscriptions();
  }


  Future<void> _restartListening() async {
  if (_isRecording) {
    try {
      await _speech.listen(
        onResult: (result) {
          final recognized = result.recognizedWords.trim();
          final now = DateTime.now();

          if (recognized.isNotEmpty) {
            bool isDuplicateText = _lastRecognized.isNotEmpty && recognized.startsWith(_lastRecognized);
            bool isTooRecent = now.difference(_lastRecognizedTime).inMilliseconds < 500;

            if (!isDuplicateText || !isTooRecent) {
              _currentText += " $recognized";
              _currentText = cleanText(_currentText);
              notifyListeners();
            }

            _lastRecognized = recognized;
            _lastRecognizedTime = now;
          }
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(minutes: 5),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );
      debugPrint('🔄 Reconocimiento reiniciado automáticamente');
    } catch (e) {
      debugPrint('Error al reiniciar reconocimiento: $e');
    }
  }
}


  Future<void> startRecording() async {
  if (!_isRecording) {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STATUS: $status');
          if (status == 'done' || status == 'notListening') {
            _restartListening();
          }
        },
        onError: (error) {
          debugPrint('ERROR: $error');
        },
      );

      if (available) {
        _lastRecognized = '';
        _lastRecognizedTime = DateTime.now();

        await _speech.listen(
          onResult: (result) {
            final recognized = result.recognizedWords.trim();
            final now = DateTime.now();

            if (recognized.isNotEmpty) {
              bool isDuplicateText = _lastRecognized.isNotEmpty && recognized.startsWith(_lastRecognized);
              bool isTooRecent = now.difference(_lastRecognizedTime).inMilliseconds < 500;

              if (!isDuplicateText || !isTooRecent) {
                _currentText += " $recognized";
                _currentText = cleanText(_currentText);
                _isPaused = false;
                _startTimer();

                notifyListeners();
              }

              _lastRecognized = recognized;
              _lastRecognizedTime = now;
            }
          },
          listenFor: const Duration(minutes: 45),
          pauseFor: const Duration(minutes: 15),
          partialResults: true,
          cancelOnError: false,
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


Future<void> pauseRecording() async {
  if (_isRecording) {
    await _speech.stop();
    _isPaused = true;
    _isRecording = false;
    _stopTimer();
    notifyListeners();
  }
}

Future<void> resumeRecording() async {
  if (_isPaused) {
    _isPaused = false;
    _isRecording = true;
    _startTimer();

    await _speech.listen(
      onResult: (result) {
        final recognized = result.recognizedWords.trim();
        final now = DateTime.now();

        bool isDuplicateText = _lastRecognized.isNotEmpty && recognized.startsWith(_lastRecognized);
        bool isTooRecent = now.difference(_lastRecognizedTime).inMilliseconds < 500;

        if (!isDuplicateText || !isTooRecent) {
          _currentText += " $recognized";
          _currentText = cleanText(_currentText);
          notifyListeners();
        }

        _lastRecognized = recognized;
        _lastRecognizedTime = now;
      },
      listenFor: const Duration(minutes: 45),
      pauseFor: const Duration(minutes: 15),
      partialResults: true,
      cancelOnError: false,
      listenMode: ListenMode.dictation,
    );

    notifyListeners();
  }
}




  String cleanText(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

  void _startTimer() {
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    _recordingDuration += const Duration(seconds: 1);
    notifyListeners();
  });
}

  void _stopTimer() {
  _timer?.cancel();
  _timer = null;
}


  Future<void> stopRecording() async {
  if (_isRecording || _isPaused) {
    await _speech.stop();
    _isRecording = false;
    _isPaused = false;
    _stopTimer();

    if (_currentText.isNotEmpty) {
      _transcriptions.insert(
        0,
        Transcription(
          title: "Grabación ${_transcriptions.length + 1}",
          text: _currentText,
          dateTime: DateTime.now(),
        ),
      );
      await saveTranscriptions();
      _currentText = '';
    }

    _recordingDuration = Duration.zero;
    notifyListeners();
  }
}



  Future<void> loadTranscriptions() async {
    var box = Hive.box('transcriptions');
    List<dynamic>? transcriptionsData = box.get("transcriptions");

    if (transcriptionsData != null) {
      _transcriptions.clear();
      for (var data in transcriptionsData) {
        _transcriptions.add(Transcription(
          title: data["title"],
          text: data["text"],
          dateTime: DateTime.parse(data["dateTime"]),
        ));
      }
      notifyListeners();
    }
  }

  Future<void> saveTranscriptions() async {
    var box = Hive.box('transcriptions');
    await box.put("transcriptions", _transcriptions.map((t) => {
      "title": t.title,
      "text": t.text,
      "dateTime": t.dateTime.toIso8601String(),
    }).toList());
  }

  void deleteTranscription(int index) {
    if (index >= 0 && index < _transcriptions.length) {
      _transcriptions.removeAt(index);
      saveTranscriptions();
      notifyListeners();
    }
  }

  void updateTitle(int index, String newTitle) {
    if (index >= 0 && index < _transcriptions.length) {
      _transcriptions[index] = Transcription(
        title: newTitle,
        text: _transcriptions[index].text,
        dateTime: _transcriptions[index].dateTime,
      );
      saveTranscriptions();
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


  void updateText(int index, String newText) {
    if (index >= 0 && index < _transcriptions.length) {
      _transcriptions[index] = Transcription(
        title: _transcriptions[index].title,
        text: newText,
        dateTime: _transcriptions[index].dateTime,
      );
      saveTranscriptions(); // 🔄 Guardar en Hive
      notifyListeners();    // 🔔 Notificar cambio a la UI
    }
  }



}

