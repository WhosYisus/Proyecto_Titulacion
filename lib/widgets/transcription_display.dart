import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/colors.dart';

class TranscriptionDisplay extends StatelessWidget {
  const TranscriptionDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<TranscriptionProvider, SettingsProvider>(
      builder: (context, transcription, settings, child) {
        return Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: settings.fontSize,
              fontFamily: settings.fontFamily,
              color: isDark 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimaryLight,
            ),
            child: Text(
              transcription.currentText.isEmpty
                  ? 'Tap and hold the microphone button to start recording...'
                  : transcription.currentText,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

