import 'package:flutter/material.dart';
import '../models/transcription.dart';

class ViewTranscriptionScreen extends StatelessWidget {
  final Transcription transcription;

  const ViewTranscriptionScreen({Key? key, required this.transcription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(transcription.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            transcription.text,
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
