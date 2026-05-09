import 'package:flutter/material.dart';

/// Global theme notifier — updated by ProfileScreen, read by IHeartYouApp
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
