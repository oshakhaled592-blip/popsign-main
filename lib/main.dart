import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/theme_notifier.dart';
import 'core/theme/language_notifier.dart';
import 'i_heart_you_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final isDark = prefs.getBool('isDark') ?? true;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final langCode = prefs.getString('langCode') ?? 'en';
  final langName = prefs.getString('langName') ?? 'English';
  final langFlag = prefs.getString('langFlag') ?? '🇺🇸';
  languageNotifier.value = LanguageInfo(
    name: langName,
    flag: langFlag,
    code: langCode,
  );

  runApp(const IHeartYouApp());
}
