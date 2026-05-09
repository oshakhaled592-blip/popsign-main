import 'package:flutter/material.dart';

class LanguageInfo {
  final String name;
  final String flag;
  final String code;

  const LanguageInfo({
    required this.name,
    required this.flag,
    required this.code,
  });
}

final languageNotifier = ValueNotifier<LanguageInfo>(
  const LanguageInfo(name: 'English', flag: '🇺🇸', code: 'en'),
);
