import 'package:flutter/material.dart';
import '../models/transcription.dart';
import '../constants/colors.dart';
import 'package:share_plus/share_plus.dart';

class TranscriptionTile extends StatelessWidget {
  final Transcription transcription;

  const TranscriptionTile({
    Key? key,
    required this.transcription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          transcription.text.length > 50
              ? '${transcription.text.substring(0, 50)}...'
              : transcription.text,
          style: TextStyle(
            color: isDark 
              ? AppColors.textPrimaryDark 
              : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          transcription.dateTime.toString().split('.')[0],
          style: TextStyle(
            color: isDark 
              ? AppColors.textSecondaryDark 
              : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.visibility,
                color: AppColors.primary,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: isDark 
                      ? AppColors.surfaceDark 
                      : AppColors.surfaceLight,
                    title: Text(
                      'Transcription',
                      style: TextStyle(
                        color: isDark 
                          ? AppColors.textPrimaryDark 
                          : AppColors.textPrimaryLight,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        transcription.text,
                        style: TextStyle(
                          color: isDark 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.download,
                color: AppColors.primary,
              ),
              onPressed: () async {
                final text = transcription.text;
                await Share.share(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}

