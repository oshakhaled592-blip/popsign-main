import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:popsign/core/data/word_data.dart';
import 'package:popsign/core/helpers/level_helper.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/app_colors.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:popsign/core/theme/styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String _currentLevel = 'A1';
  int _totalWords = 0;
  int _completedLevels = 0;
  double _currentLevelProgress = 0;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
    _loadData();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final level = prefs.getString('userLevel') ?? 'A1';
    final langCode = prefs.getString('langCode') ?? 'en';

    // Count total words learned (progress == 3) across all levels/languages
    int totalWords = 0;
    int completedLevels = 0;

    for (final lvl in allLevels) {
      final saved = prefs.getString('progress_${langCode}_$lvl');
      if (saved == null || saved.isEmpty) continue;
      final parts = saved.split(',');
      int doneInLevel = 0;
      for (final p in parts) {
        if ((int.tryParse(p) ?? 0) >= 3) {
          totalWords++;
          doneInLevel++;
        }
      }
      final levelWordCount = getWords(langCode, lvl).length;
      if (levelWordCount > 0 && doneInLevel >= levelWordCount) {
        completedLevels++;
      }
    }

    // Current level progress %
    double progress = 0;
    final currentSaved = prefs.getString('progress_${langCode}_$level');
    if (currentSaved != null && currentSaved.isNotEmpty) {
      final parts = currentSaved.split(',');
      final done = parts.fold(0, (acc, p) => acc + (int.tryParse(p) ?? 0));
      final wordCount = getWords(langCode, level).length;
      final maxProgress = wordCount * 3;
      if (maxProgress > 0) progress = (done / maxProgress) * 100;
    }

    if (mounted) {
      setState(() {
        _currentLevel = level;
        _totalWords = totalWords;
        _completedLevels = completedLevels;
        _currentLevelProgress = progress.clamp(0, 100);
        _loading = false;
      });
    }
  }

  static const _levelColors = {
    'A1': AppColors.a1Color,
    'A2': AppColors.a2Color,
    'B1': AppColors.b1Color,
    'B2': AppColors.b2Color,
    'C1': AppColors.c1Color,
    'C2': AppColors.c2Color,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF2F4FA);
    final cardBg = isDark ? const Color(0xFF141829) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white54 : Colors.grey.shade500;
    final levelColor = _levelColors[_currentLevel] ?? AppColors.a1Color;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        S.get('dashboard_title'),
                        style: AppTextStyles.font24BoldWhite.copyWith(
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        S.get('track_progress'),
                        style: TextStyle(color: subColor, fontSize: 14.sp),
                      ),
                      SizedBox(height: 28.h),

                      // Current Level card
                      _buildCard(
                        cardBg: cardBg,
                        accentColor: levelColor,
                        icon: Icons.school_rounded,
                        label: S.get('current_level'),
                        value: _currentLevel,
                        sub: S.get('selected_cefr'),
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      SizedBox(height: 14.h),

                      // Words learned card
                      _buildCard(
                        cardBg: cardBg,
                        accentColor: const Color(0xFF22C55E),
                        icon: Icons.menu_book_rounded,
                        label: S.get('words_learned'),
                        value: '$_totalWords ${S.get('words_unit')}',
                        sub: S.get('across_levels'),
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      SizedBox(height: 14.h),

                      // Completed levels card
                      _buildCard(
                        cardBg: cardBg,
                        accentColor: const Color(0xFF6366F1),
                        icon: Icons.emoji_events_rounded,
                        label: S.get('completed_levels'),
                        value: '$_completedLevels / ${allLevels.length}',
                        sub: S.get('levels_mastered'),
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      SizedBox(height: 14.h),

                      // Progress in current level
                      Container(
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: levelColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bar_chart_rounded,
                                    color: levelColor, size: 22.sp),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    '${S.get('progress_in')} $_currentLevel',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${_currentLevelProgress.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: levelColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: LinearProgressIndicator(
                                value: _currentLevelProgress / 100,
                                minHeight: 10.h,
                                backgroundColor: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade200,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(levelColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Go to Levels button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, Routes.levels),
                          icon: const Icon(Icons.layers_rounded),
                          label: Text(
                            S.get('go_to_levels'),
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: levelColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color cardBg,
    required Color accentColor,
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color textColor,
    required Color subColor,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: accentColor, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: subColor, fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Text(value,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2.h),
                Text(sub, style: TextStyle(color: subColor, fontSize: 11.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
