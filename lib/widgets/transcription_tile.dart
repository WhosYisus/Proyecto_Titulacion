import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';
import '../models/transcription.dart';
import '../screens/view_transcription_screen.dart'; // 🔥 Nueva pantalla
import '../utils/file_saver.dart';

class TranscriptionTile extends StatelessWidget {
  final Transcription transcription;
  final int index;

  const TranscriptionTile({Key? key, required this.transcription, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // 🔥 Ir a la pantalla de visualización detallada
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewTranscriptionScreen(transcription: transcription),
            ),
          );
        },
        onLongPress: () {
          // 🔥 Mostrar opciones al mantener presionado
          _showOptions(context);
        },
        child: ListTile(
          title: Text(
            transcription.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            '${transcription.dateTime.day}/${transcription.dateTime.month}/${transcription.dateTime.year}',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar título'),
            onTap: () {
              Navigator.pop(context);
              _editTitle(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver grabación'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewTranscriptionScreen(transcription: transcription),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Descargar'),
            onTap: () async {
              Navigator.pop(context);
              await FileSaver.saveTextFile(transcription.text, transcription.title);
            },
          ),
          ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
          ),

        ],
      ),
    );
  }

  void _editTitle(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: transcription.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Título'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nuevo título'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TranscriptionProvider>(context, listen: false)
                  .updateTitle(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

    void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta grabación?'),
        content: const Text('Esta acción no se puede deshacer. ¿Deseas continuar?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<TranscriptionProvider>(context, listen: false)
                  .deleteTranscription(index);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }



}
