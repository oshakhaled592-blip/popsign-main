import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'i_heart_you_app.dart';
import 'core/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load saved theme before the first frame so every screen (including
  // the splash) renders with the correct light/dark mode immediately.
  final prefs = await SharedPreferences.getInstance();
  final savedDark = prefs.getBool('isDark');
  if (savedDark != null) {
    themeNotifier.value = savedDark ? ThemeMode.dark : ThemeMode.light;
  }

  runApp(const IHeartYouApp());
}

