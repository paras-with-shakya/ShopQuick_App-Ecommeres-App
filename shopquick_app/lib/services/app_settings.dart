import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
  static final ValueNotifier<String> language = ValueNotifier<String>('en');

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    darkMode.value = _prefs.getBool('darkMode') ?? false;
    language.value = _prefs.getString('language') ?? 'en';
  }

  static Future<void> setDarkMode(bool value) async {
    darkMode.value = value;
    await _prefs.setBool('darkMode', value);
  }

  static Future<void> setLanguage(String lang) async {
    language.value = lang;
    await _prefs.setString('language', lang);
  }
}
