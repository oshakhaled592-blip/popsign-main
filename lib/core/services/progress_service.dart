import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningLevel {
  final int minWords;
  final String name;
  final String emoji;
  final Color color;

  const LearningLevel({
    required this.minWords,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

class ProgressService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const levels = [
    LearningLevel(minWords: 0,   name: 'Beginner',     emoji: '🌱', color: Color(0xFF00B894)),
    LearningLevel(minWords: 5,   name: 'Learner',      emoji: '📖', color: Color(0xFF74B816)),
    LearningLevel(minWords: 15,  name: 'Intermediate', emoji: '⭐', color: Color(0xFFD4AC0D)),
    LearningLevel(minWords: 30,  name: 'Advanced',     emoji: '🔥', color: Color(0xFFD96C06)),
    LearningLevel(minWords: 60,  name: 'Expert',       emoji: '💎', color: Color(0xFFFF5722)),
    LearningLevel(minWords: 100, name: 'Master',       emoji: '🏆', color: Color(0xFFE91E63)),
  ];

  static const _allCefr  = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const _allLangs = ['en', 'ar'];

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'words_channel',
      'Learning Progress',
      description: 'Notifications about your word learning progress',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<int> getTotalWordsLearned() async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;
    for (final lang in _allLangs) {
      for (final lvl in _allCefr) {
        final saved = prefs.getString('progress_${lang}_$lvl');
        if (saved == null || saved.isEmpty) continue;
        for (final p in saved.split(',')) {
          if ((int.tryParse(p) ?? 0) >= 3) total++;
        }
      }
    }
    return total;
  }

  static LearningLevel getCurrentLevel(int totalWords) {
    LearningLevel current = levels.first;
    for (final lvl in levels) {
      if (totalWords >= lvl.minWords) current = lvl;
    }
    return current;
  }

  static LearningLevel? getNextLevel(int totalWords) {
    for (final lvl in levels) {
      if (totalWords < lvl.minWords) return lvl;
    }
    return null;
  }

  // Called when every word in a CEFR level reaches progress 3.
  // Unlocks the next level and fires a notification (once per completion).
  static Future<void> onCefrLevelCompleted({required String cefrLevel}) async {
    await init();

    final prefs = await SharedPreferences.getInstance();

    // Only fire once per level (reset when the user resets that level's progress)
    final completionKey = 'cefr_completed_$cefrLevel';
    if (prefs.getBool(completionKey) == true) return;
    await prefs.setBool(completionKey, true);

    final idx = _allCefr.indexOf(cefrLevel);
    if (idx < 0) return;

    if (idx >= _allCefr.length - 1) {
      // All levels done — C2 finished
      await _showNotification(
        id: 20,
        title: '🏆 You mastered all levels!',
        body: 'Incredible! You have completed every sign language level!',
      );
      return;
    }

    final nextLevel = _allCefr[idx + 1];

    // Advance userLevel only if it hasn't already been set higher
    final currentUserLevel = prefs.getString('userLevel') ?? 'A1';
    final currentUserIdx = _allCefr.indexOf(currentUserLevel);
    if (idx + 1 > currentUserIdx) {
      await prefs.setString('userLevel', nextLevel);
    }

    await _showNotification(
      id: 10 + idx,
      title: '🎉 Level $cefrLevel Complete!',
      body: 'Amazing work! Level $nextLevel is now unlocked! 🔓',
    );
  }

  // Called after each word is learned (progress reaches 3)
  static Future<void> onWordLearned() async {
    await init();

    final prefs = await SharedPreferences.getInstance();
    final oldTotal = prefs.getInt('total_words_learned') ?? 0;
    final newTotal = await getTotalWordsLearned();

    if (newTotal <= oldTotal) return;
    await prefs.setInt('total_words_learned', newTotal);

    final oldLevel = getCurrentLevel(oldTotal);
    final newLevel = getCurrentLevel(newTotal);
    final leveledUp = oldLevel.name != newLevel.name;

    if (leveledUp) {
      await _showNotification(
        id: 2,
        title: '${newLevel.emoji} Level Up!',
        body:
            'You reached ${newLevel.name}! You\'ve learned $newTotal word${newTotal == 1 ? '' : 's'} total.',
      );
    } else {
      await _showNotification(
        id: 1,
        title: 'Great job! 🎉',
        body:
            'You\'ve learned $newTotal word${newTotal == 1 ? '' : 's'} total! Keep going!',
      );
    }
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'words_channel',
        'Learning Progress',
        channelDescription: 'Notifications about your word learning progress',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
    );
    await _plugin.show(id, title, body, details);
  }
}
