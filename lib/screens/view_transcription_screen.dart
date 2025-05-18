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
  final TextEditingController _promptController = TextEditingController();
  String? aiResponse;
  bool isLoading = false;
  bool isImproving = false;

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

  Future<void> _handlePrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      aiResponse = null;
    });

    final response = await customPromptToAI(prompt, displayedText);

    setState(() {
      isLoading = false;
      aiResponse = response ?? 'Ocurrió un error al procesar tu solicitud.';
    });
  }

  Future<void> _handleImproveText() async {
    setState(() {
      isImproving = true;
    });

    final improved = await improveTextWithAI(displayedText);

    setState(() {
      isImproving = false;
    });

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
                _updateText(improved);
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transcription.title),
        actions: [
          isImproving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.auto_fix_high),
                  tooltip: 'Mejorar texto',
                  onPressed: _handleImproveText,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
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
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'Pregunta lo que quieras',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handlePrompt,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const CircularProgressIndicator()
            else if (aiResponse != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SelectableText(
                  aiResponse!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
