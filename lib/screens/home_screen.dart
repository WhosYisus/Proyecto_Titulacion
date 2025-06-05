import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/transcription_display.dart';
import '../providers/transcription_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TranscriptionProvider>(
          builder: (context, provider, _) {
            final isRecording = provider.isRecording;
            final isPaused = provider.isPaused;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'APP',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const HistoryScreen(),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const SettingsScreen(),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Expanded(child: TranscriptionDisplay()),

                // 🕒 Temporizador
                if (isRecording || isPaused)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      formatDuration(provider.recordingDuration),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),

                // 🎛️ Botones de control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isRecording || isPaused)
                        FloatingActionButton(
                          heroTag: 'pause_resume',
                          backgroundColor: isPaused ? Colors.green : Colors.orange,
                          onPressed: () {
                            if (isPaused) {
                              provider.resumeRecording();
                            } else {
                              provider.pauseRecording();
                            }
                          },
                          child: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                        ),

                      if (isRecording || isPaused)
                        FloatingActionButton(
                          heroTag: 'stop',
                          backgroundColor: Colors.red,
                          onPressed: () {
                            provider.stopRecording();
                          },
                          child: const Icon(Icons.stop),
                        ),

                      if (!isRecording && !isPaused)
                        FloatingActionButton(
                          heroTag: 'start',
                          backgroundColor: Colors.deepPurple,
                          onPressed: () {
                            provider.startRecording();
                          },
                          child: const Icon(Icons.mic),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
