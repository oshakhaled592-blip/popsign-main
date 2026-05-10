import 'package:flutter/material.dart';
import 'package:popsign/core/data/word_data.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'learn_new_words_screen.dart';

/// ================= MODEL =================
class WordModel {
  String word;
  int progress;
  String image;

  WordModel(this.word, this.progress, this.image);

  bool get isDone => progress == 3;
}

final _images = [
  'assets/images/mother.png','assets/images/day.png',
  'assets/images/you.png',   'assets/images/get.png',
  'assets/images/put.png',   'assets/images/race.png',
  'assets/images/start.png', 'assets/images/finish.png',
  'assets/images/design.png','assets/images/mother.png',
];

List<WordModel> _wordsForLang(String code, String level) {
  final list = getWords(code, level);
  return List.generate(
    list.length,
    (i) => WordModel(list[i], 0, _images[i % _images.length]),
  );
}

/// ================= SCREEN =================
class WordListScreen extends StatefulWidget {
  final String level;

  const WordListScreen({super.key, this.level = 'A1'});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final _scrollController = ScrollController();
  late List<WordModel> words;
  late String _currentLangCode;

  String get _progressKey => 'progress_${_currentLangCode}_${widget.level}';

  @override
  void initState() {
    super.initState();
    _currentLangCode = languageNotifier.value.code;
    words = _wordsForLang(_currentLangCode, widget.level);
    languageNotifier.addListener(_onLangChanged);
    _loadProgress(_currentLangCode);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, words.map((w) => w.progress).join(','));
  }

  Future<void> _loadProgress(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'progress_${langCode}_${widget.level}';
    final saved = prefs.getString(key);
    if (saved != null && mounted) {
      final parts = saved.split(',');
      setState(() {
        for (int i = 0; i < words.length && i < parts.length; i++) {
          words[i].progress = int.tryParse(parts[i]) ?? 0;
        }
      });
    }
  }

  void _onLangChanged() {
    final newCode = languageNotifier.value.code;
    if (newCode != _currentLangCode) {
      _saveProgress();
      setState(() {
        _currentLangCode = newCode;
        words = _wordsForLang(newCode, widget.level);
      });
      _loadProgress(newCode);
    }
  }

  @override
  void dispose() {
    languageNotifier.removeListener(_onLangChanged);
    _scrollController.dispose();
    super.dispose();
  }

  int get remaining => words.where((w) => w.progress < 3).length;

  int get percent {
    final total = words.length * 3;
    final done = words.fold(0, (sum, w) => sum + w.progress);
    return ((done / total) * 100).toInt();
  }

  void onLearn(int index) async {
    setState(() {
      if (words[index].progress < 3) words[index].progress++;
    });
    _saveProgress();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearnNewWordsScreen(
          passedWord: words[index].word,
          level: widget.level,
        ),
      ),
    );
  }

  Future<void> showResetDialog() async {
    final result = await Navigator.pushNamed(context, Routes.reset);
    if (result == true) {
      setState(() {
        for (var word in words) {
          word.progress = 0;
        }
      });
      _saveProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final subTextColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,

        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.profile),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu, color: textColor),
            ),
          ),
        ),

        title: ValueListenableBuilder<LanguageInfo>(
          valueListenable: languageNotifier,
          builder: (_, lang, __) => Text(
            "${lang.flag}  ${lang.name}",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: textColor),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 14),

          GestureDetector(
            onTap: showResetDialog,
            child: Container(
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: textColor.withValues(alpha: 0.08)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      S.get('reset_all'),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "$remaining ${S.get('words_left')}  •  $percent% ${S.get('complete')}",
            style: TextStyle(color: subTextColor, fontSize: 16),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(8),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final item = words[index];
                  return WordCard(
                    word: item.word,
                    image: item.image,
                    progress: item.progress,
                    isDone: item.isDone,
                    onTap: () => onLearn(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= WORD CARD =================
class WordCard extends StatelessWidget {
  final String word;
  final String image;
  final int progress;
  final bool isDone;
  final VoidCallback onTap;

  const WordCard({
    super.key,
    required this.word,
    required this.image,
    required this.progress,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final dimColor = isDark ? const Color(0xFF31384A) : Colors.grey.shade300;
    final inactiveColor = isDark ? const Color(0xFF232938) : Colors.grey.shade200;

    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              word,
              style: TextStyle(
                color: isDone ? textColor.withValues(alpha: 0.38) : textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Row(
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i < progress ? Colors.green : dimColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          const SizedBox(width: 14),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : inactiveColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check,
              color: isDone ? Colors.white : textColor.withValues(alpha: 0.38),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: isDone ? null : onTap,
            child: Container(
              width: 74,
              height: 40,
              decoration: BoxDecoration(
                color: isDone ? inactiveColor : textColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  S.get('learn'),
                  style: TextStyle(
                    color: isDone
                        ? textColor.withValues(alpha: 0.38)
                        : Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
