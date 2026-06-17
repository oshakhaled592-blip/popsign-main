import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/data/word_data.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/services/progress_service.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordModel {
  String word;
  int progress;
  String image;

  WordModel(this.word, this.progress, this.image);

  bool get isDone => progress == 3;
}

final _images = [
  'assets/images/mother.png', 'assets/images/day.png',
  'assets/images/you.png',    'assets/images/get.png',
  'assets/images/put.png',    'assets/images/race.png',
  'assets/images/start.png',  'assets/images/finish.png',
  'assets/images/design.png', 'assets/images/mother.png',
];

List<WordModel> _wordsForLang(String code, String level) {
  final list = getWords(code, level);
  return List.generate(
    list.length,
    (i) => WordModel(list[i], 0, _images[i % _images.length]),
  );
}

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
    final result = await Navigator.pushNamed(
      context,
      Routes.signPractice,
      arguments: words[index].word,
    );

    if (result == true && mounted) {
      final wasNotDone = words[index].progress < 3;
      setState(() {
        if (wasNotDone) words[index].progress++;
      });
      await _saveProgress();
      if (wasNotDone && words[index].progress == 3) {
        ProgressService.onWordLearned();
      }
    }
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
          padding: EdgeInsets.only(left: 12.w),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.profile),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu, color: textColor, size: 22.sp),
            ),
          ),
        ),

        title: ValueListenableBuilder<LanguageInfo>(
          valueListenable: languageNotifier,
          builder: (context, lang, child) => Text(
            "${lang.flag}  ${lang.name}",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: textColor, size: 22.sp),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: 14.h),

          GestureDetector(
            onTap: showResetDialog,
            child: Container(
              height: 58.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: textColor.withValues(alpha: 0.08)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 10.w),
                    Text(
                      S.get('reset_all'),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 18.h),

          Text(
            "$remaining ${S.get('words_left')}  •  $percent% ${S.get('complete')}",
            style: TextStyle(color: subTextColor, fontSize: 16.sp),
          ),

          SizedBox(height: 18.h),

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
      height: 72.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              word,
              style: TextStyle(
                color: isDone ? textColor.withValues(alpha: 0.38) : textColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Row(
            children: List.generate(3, (i) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: i < progress ? Colors.green : dimColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          SizedBox(width: 14.w),

          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : inactiveColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check,
              color: isDone ? Colors.white : textColor.withValues(alpha: 0.38),
              size: 20.sp,
            ),
          ),

          SizedBox(width: 12.w),

          GestureDetector(
            onTap: isDone ? null : onTap,
            child: Container(
              width: 74.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isDone ? inactiveColor : textColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  S.get('learn'),
                  style: TextStyle(
                    color: isDone
                        ? textColor.withValues(alpha: 0.38)
                        : Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 16.sp,
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
