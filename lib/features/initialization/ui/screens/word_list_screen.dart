import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/data/word_translations.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/services/levels_service.dart';
import 'package:popsign/core/services/progress_service.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:popsign/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordModel {
  String word;
  String englishWord;
  String videoUrl;
  int progress;

  WordModel(this.word, this.videoUrl, this.progress, {this.englishWord = ''});

  bool get isDone => progress == 3;
  String get matchWord => englishWord.isEmpty ? word : englishWord;
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
  bool _loadingApi = true;

  String get _progressKey => 'progress_${_currentLangCode}_${widget.level}';

  @override
  void initState() {
    super.initState();
    _currentLangCode = languageNotifier.value.code;
    words = [];
    languageNotifier.addListener(_onLangChanged);
    _fetchFromApi();
  }

  Future<void> _fetchFromApi() async {
    if (mounted) setState(() => _loadingApi = true);
    final apiData = await LevelsService().getLevels();
    final levelWords = apiData[widget.level];
    if (levelWords != null && levelWords.isNotEmpty && mounted) {
      final saved = await _getSavedProgress();
      setState(() {
        words = levelWords.asMap().entries.map((e) {
          final englishWord = e.value.word;
          final displayWord = translateWord(englishWord, _currentLangCode);
          return WordModel(
            displayWord,
            e.value.videoUrl,
            saved != null && e.key < saved.length ? saved[e.key] : 0,
            englishWord: englishWord,
          );
        }).toList();
        _loadingApi = false;
      });
    } else if (mounted) {
      setState(() => _loadingApi = false);
    }
  }

  Future<List<int>?> _getSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_progressKey);
    if (saved == null) return null;
    return saved.split(',').map((s) => int.tryParse(s) ?? 0).toList();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, words.map((w) => w.progress).join(','));
  }

  void _onLangChanged() {
    final newCode = languageNotifier.value.code;
    if (newCode != _currentLangCode) {
      _saveProgress();
      _currentLangCode = newCode;
      _fetchFromApi();
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
    if (words.isEmpty) return 0;
    final total = words.length * 3;
    final done = words.fold(0, (sum, w) => sum + w.progress);
    return ((done / total) * 100).toInt();
  }

  void onLearn(int index) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.signPractice,
      arguments: {
        'word': words[index].word,
        'englishWord': words[index].matchWord,
        'videoUrl': words[index].videoUrl,
      },
    );

    if (!mounted) return;

    if (result == 'done') {
      // "I know this sign" — mark word as fully complete
      final wasNotDone = words[index].progress < 3;
      setState(() => words[index].progress = 3);
      await _saveProgress();
      if (wasNotDone) {
        ProgressService.onWordLearned();
        _checkLevelComplete();
      }
    } else if (result == true) {
      // Correct camera prediction — add one dot (need 3 to finish)
      final wasNotDone = words[index].progress < 3;
      setState(() {
        if (wasNotDone) words[index].progress++;
      });
      await _saveProgress();
      if (wasNotDone && words[index].progress == 3) {
        ProgressService.onWordLearned();
        _checkLevelComplete();
      }
    }
  }

  void _checkLevelComplete() {
    if (words.isNotEmpty && words.every((w) => w.progress >= 3)) {
      ProgressService.onCefrLevelCompleted(cefrLevel: widget.level);
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
      // Allow the level-complete notification to fire again after a reset
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cefr_completed_${widget.level}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
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
                    Icon(Icons.refresh, color: AppColors.error, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(
                      S.get('reset_all'),
                      style: TextStyle(
                        color: AppColors.error,
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

          if (_loadingApi)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Loading words...',
                  style: TextStyle(color: subTextColor, fontSize: 13.sp),
                ),
              ],
            )
          else
            Text(
              "$remaining ${S.get('words_left')}  •  $percent% ${S.get('complete')}",
              style: TextStyle(color: subTextColor, fontSize: 16.sp),
            ),

          SizedBox(height: 18.h),

          Expanded(
            child: SafeArea(
              top: false,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 4.w,
                radius: Radius.circular(8.r),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final item = words[index];
                    return WordCard(
                      word: item.word,
                      videoUrl: item.videoUrl,
                      progress: item.progress,
                      isDone: item.isDone,
                      onTap: () => onLearn(index),
                    );
                  },
                ),
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
  final String videoUrl;
  final int progress;
  final bool isDone;
  final VoidCallback onTap;

  const WordCard({
    super.key,
    required this.word,
    required this.videoUrl,
    required this.progress,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final dimColor = isDark ? const Color(0xFF31384A) : Colors.grey.shade300;
    final inactiveColor = isDark ? const Color(0xFF232938) : Colors.grey.shade200;
    const accent = AppColors.accent;

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
          if (videoUrl.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Icon(Icons.play_circle_outline_rounded,
                  color: accent, size: 22.sp),
            ),

          Expanded(
            child: Text(
              word,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                  color: i < progress ? AppColors.success : dimColor,
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
              color: isDone ? AppColors.success : inactiveColor,
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
                color: isDone ? inactiveColor : accent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  S.get('learn'),
                  style: TextStyle(
                    color: isDone
                        ? textColor.withValues(alpha: 0.38)
                        : Colors.white,
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
