import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';
import '../widgets/transcription_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TranscriptionProvider>(
        builder: (context, provider, child) {
          return provider.transcriptions.isEmpty
              ? const Center(child: Text('No hay transcripciones aún'))
              : ListView.builder(
                  itemCount: provider.transcriptions.length,
                  itemBuilder: (context, index) {
                    final transcription = provider.transcriptions[index];
                    return TranscriptionTile(transcription: transcription, index: index);
                  },
                );
        },
      ),
    );
  }
}
