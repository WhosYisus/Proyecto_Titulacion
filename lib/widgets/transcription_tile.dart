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
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';

class TranscriptionTile extends StatelessWidget {
  final Transcription transcription;
  final int index;

  const TranscriptionTile({
    Key? key,
    required this.transcription,
    required this.index,
  }) : super(key: key);

  Future<void> _editTitle(BuildContext context) async {
    TextEditingController controller = TextEditingController(text: transcription.title);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Título"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nuevo título"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TranscriptionProvider>(context, listen: false)
                  .updateTitle(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showTranscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transcription.title),
        content: SingleChildScrollView(
          child: Text(transcription.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (kIsWeb) {
      final blob = html.Blob([utf8.encode(transcription.text)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "transcription_${transcription.dateTime.toIso8601String()}.txt")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar(context, 'Permiso de almacenamiento denegado.');
          return;
        }

        Directory? directory = await getExternalStorageDirectory();
        if (directory == null) {
          _showSnackBar(context, 'Error al acceder al almacenamiento.');
          return;
        }

        String fileName = 'transcription_${transcription.dateTime.toIso8601String()}.txt';
        String filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsString(transcription.text);

        _showSnackBar(context, 'Archivo guardado en: $filePath');
        OpenFile.open(filePath);
      } catch (e) {
        debugPrint('Error al guardar archivo: $e');
        _showSnackBar(context, 'Error al guardar archivo.');
      }
    }
  }



  void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Eliminar Grabación"),
      content: const Text("¿Estás seguro de que deseas eliminar esta grabación? Esta acción no se puede deshacer."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            Provider.of<TranscriptionProvider>(context, listen: false)
                .deleteTranscription(index);
            Navigator.pop(context);
          },
          child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          transcription.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          '${transcription.dateTime.day}/${transcription.dateTime.month}/${transcription.dateTime.year}',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editTitle(context),
            ),
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _showTranscriptionDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadFile(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
              ),
          ],
        ),
      ),
    );
  }
}
