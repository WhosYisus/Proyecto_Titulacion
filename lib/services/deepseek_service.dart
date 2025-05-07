import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa dotenv

Future<String?> improveTextWithAI(String text) async {
  final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
  //debugPrint("🔑 API Key cargada: $apiKey");



  const endpoint = 'https://api.deepseek.com/v1/chat/completions';

  final prompt = '''
  Corrige y mejora el siguiente texto sin cambiar la idea principal. Hazlo más claro y profesional, eliminando repeticiones, muletillas y errores gramaticales. Evita completamente los acentos (á, é, í, ó, ú) para prevenir errores de codificación. No uses comillas en preguntas ni expliques nada. Solo responde con el texto corregido y en formato plano, sin listas ni marcas especiales. Respeta signos como ¿ y ?.

  $text
  ''';


  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "deepseek-chat",
        "messages": [
          {"role": "system", "content": "Eres un corrector de texto profesional."},
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'];
    } else {
      debugPrint('Error al llamar a la IA: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error de red o procesamiento: $e');
  }

  return null;
}
