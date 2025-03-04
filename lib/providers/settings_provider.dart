import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  double _fontSize = 16;
  String _fontFamily = 'Poppins';
  

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  

  SettingsProvider() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _fontSize = _prefs?.getDouble('fontSize') ?? 16;
    _fontFamily = _prefs?.getString('fontFamily') ?? 'Poppins';
    
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _prefs?.setDouble('fontSize', size);
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    await _prefs?.setString('fontFamily', family);
    notifyListeners();
  }

  
}

