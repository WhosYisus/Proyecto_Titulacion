import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';
import '../widgets/transcription_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TranscriptionProvider>(
        builder: (context, provider, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: provider.transcriptions.isEmpty
                ? const Center(
                    child: Text('No transcriptions yet'),
                  )
                : ListView.builder(
                    itemCount: provider.transcriptions.length,
                    itemBuilder: (context, index) {
                      final transcription = provider.transcriptions[index];
                      return TranscriptionTile(transcription: transcription);
                    },
                  ),
          );
        },
      ),
    );
  }
}

