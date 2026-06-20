import '../data/levels_video_data.dart';

class LevelWord {
  final String word;
  final String videoUrl;
  const LevelWord({required this.word, required this.videoUrl});
}

class LevelsService {

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
    return _hardcoded;
  }
}
