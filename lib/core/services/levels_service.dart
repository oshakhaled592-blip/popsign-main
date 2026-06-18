import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/levels_video_data.dart';

class LevelWord {
  final String word;
  final String videoUrl;
  const LevelWord({required this.word, required this.videoUrl});
}

class LevelsService {
  static const _base = 'http://91.108.113.135';
  static const _timeout = Duration(seconds: 15);

  static Map<String, List<LevelWord>> get _hardcoded => levelsVideoData.map(
        (key, words) => MapEntry(
          key,
          words
              .where((w) => w['word']!.isNotEmpty)
              .map((w) => LevelWord(word: w['word']!, videoUrl: w['url']!))
              .toList(),
        ),
      );

  Future<Map<String, List<LevelWord>>> getLevels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null || token.isEmpty) return _hardcoded;

      final res = await http.get(
        Uri.parse('$_base/api/levels/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (res.statusCode != 200) return _hardcoded;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['success'] != true) return _hardcoded;

      final result = <String, List<LevelWord>>{};
      for (final level in json['levels'] as List) {
        final id = (level['id'] ?? level['name'] ?? '').toString();
        final words = (level['words'] as List? ?? []).map((w) {
          return LevelWord(
            word: (w['word'] ?? '').toString(),
            videoUrl: (w['url'] ?? '').toString(),
          );
        }).where((w) => w.word.isNotEmpty).toList();
        if (id.isNotEmpty) result[id] = words;
      }
      return result.isNotEmpty ? result : _hardcoded;
    } catch (_) {
      return _hardcoded;
    }
  }
}
