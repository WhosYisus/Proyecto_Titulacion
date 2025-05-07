import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';  
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/transcription_provider.dart';
import 'providers/settings_provider.dart';
import 'constants/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("❌ Error cargando .env: $e");
  }
  
  await Hive.initFlutter();
  if (kIsWeb) {
    await Hive.openBox('transcriptions');
  } else {
    await Hive.openBox('transcriptions');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TranscriptionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          surface: AppColors.surfaceLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
          bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
        ),
        cardTheme: CardTheme(
          color: AppColors.surfaceLight,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
          bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
        ),
        cardTheme: CardTheme(
          color: AppColors.surfaceDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

