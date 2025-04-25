import 'package:flutter/services.dart';

typedef PartialResultCallback = void Function(String text);

class VoskService {
  static const MethodChannel _channel = MethodChannel('vosk');
  static PartialResultCallback? _onPartialResult;

  static void setPartialResultCallback(PartialResultCallback callback) {
    _onPartialResult = callback;
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static Future<void> start() async {
    try {
      await _channel.invokeMethod('startVosk');
    } on PlatformException catch (e) {
      print('Error al iniciar VOSK: ${e.message}');
    }
  }

  static Future<String?> stop() async {
    try {
      final result = await _channel.invokeMethod('stopVosk');
      return result;
    } on PlatformException catch (e) {
      print('Error al detener VOSK: ${e.message}');
      return null;
    }
  }

  static Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onPartialResult') {
      final String partial = call.arguments as String;
      _onPartialResult?.call(partial);
    }
  }
}
