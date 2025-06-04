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
    debugPrint("Error cargando .env: $e");
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
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Voice Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}


