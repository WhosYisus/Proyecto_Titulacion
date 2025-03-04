import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'dart:html' as html;
import '../models/transcription.dart';
import '../constants/colors.dart';

class TranscriptionTile extends StatelessWidget {
  final Transcription transcription;

  const TranscriptionTile({
    Key? key,
    required this.transcription,
  }) : super(key: key);

  Future<void> _downloadFile(BuildContext context) async {
    if (kIsWeb) {
      // 📌 Código para Flutter Web (descargar archivo en el navegador)
      final blob = html.Blob([utf8.encode(transcription.text)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "transcription_${transcription.dateTime.toIso8601String()}.txt")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // 📌 Código para Android
      try {
        // Pedir permisos de almacenamiento
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar(context, 'Permiso de almacenamiento denegado.');
          return;
        }

        // Obtener directorio de almacenamiento
        Directory? directory = await getExternalStorageDirectory();
        if (directory == null) {
          _showSnackBar(context, 'Error al acceder al almacenamiento.');
          return;
        }

        // Crear archivo
        String fileName = 'transcription_${transcription.dateTime.toIso8601String()}.txt';
        String filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsString(transcription.text);

        // Notificar al usuario y permitir abrir el archivo
        _showSnackBar(context, 'Archivo guardado en: $filePath');
        OpenFile.open(filePath);
      } catch (e) {
        debugPrint('Error al guardar archivo: $e');
        _showSnackBar(context, 'Error al guardar archivo.');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          transcription.text.length > 50
              ? '${transcription.text.substring(0, 50)}...'
              : transcription.text,
          style: TextStyle(
            color: isDark 
              ? AppColors.textPrimaryDark 
              : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          '${transcription.dateTime.day}/${transcription.dateTime.month}/${transcription.dateTime.year}',
          style: TextStyle(
            color: isDark 
              ? AppColors.textSecondaryDark 
              : AppColors.textSecondaryLight,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.download,
            color: AppColors.primary,
          ),
          onPressed: () => _downloadFile(context),
        ),
      ),
    );
  }
}
