import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';
import '../constants/colors.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptionProvider>(
      builder: (context, provider, child) {
        return InkWell(
          onTap: () {
            if (provider.isRecording) {
              provider.stopRecording();
            } else {
              provider.startRecording();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: provider.isRecording ? 80 : 64,
            height: provider.isRecording ? 80 : 64,
            decoration: BoxDecoration(
              color: provider.isRecording 
                ? AppColors.recordingActive 
                : AppColors.recordingStart,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (provider.isRecording 
                    ? AppColors.recordingActive 
                    : AppColors.recordingStart).withOpacity(0.3),
                  blurRadius: provider.isRecording ? 20 : 10,
                  spreadRadius: provider.isRecording ? 5 : 0,
                ),
              ],
            ),
            child: Icon(
              provider.isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: provider.isRecording ? 40 : 32,
            ),
          ),
        );
      },
    );
  }
}

