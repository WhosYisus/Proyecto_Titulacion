import 'package:flutter/material.dart';
import '../models/transcription.dart';
import '../utils/file_saver.dart';
import '../services/deepseek_service.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';

class ViewTranscriptionScreen extends StatefulWidget {
  final Transcription transcription;
  final int index;

  const ViewTranscriptionScreen({Key? key, required this.transcription, required this.index}) : super(key: key);

  @override
  State<ViewTranscriptionScreen> createState() => _ViewTranscriptionScreenState();
}

class _ViewTranscriptionScreenState extends State<ViewTranscriptionScreen> {
  late String displayedText;

  @override
  void initState() {
    super.initState();
    displayedText = widget.transcription.text;
  }

  void _updateText(String newText) {
    setState(() {
      displayedText = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transcription.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Mejorar texto',
            onPressed: () async {
              final improved = await improveTextWithAI(displayedText);
              if (improved != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Texto mejorado'),
                    content: SingleChildScrollView(child: Text(improved)),
                    actions: [
                      TextButton(
                        child: const Text('Cerrar'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Reemplazar original'),
                        onPressed: () {
                          Provider.of<TranscriptionProvider>(context, listen: false)
                              .updateText(widget.index, improved);
                          _updateText(improved); // 🔥 Refresca la vista actual
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Texto reemplazado exitosamente')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            displayedText,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
