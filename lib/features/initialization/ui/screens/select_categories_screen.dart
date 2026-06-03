import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/widgets/linear_button.dart';
import 'pre_start_screen.dart';

class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<SelectCategoriesScreen> createState() =>
      _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  final _scrollController = ScrollController();
  int? selectedIndex;

  // نسب التقدم الحقيقية لكل مستوى
  final Map<String, double> _realProgress = {};

  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  final List<Map<String, dynamic>> categories = [
    {'level': 'A1', 'words': '1 - 100 words',   'color': const Color(0xFF00B894)},
    {'level': 'A2', 'words': '101 - 1k words',  'color': const Color(0xFF74B816)},
    {'level': 'B1', 'words': '1k - 2k words',   'color': const Color(0xFFD4AC0D)},
    {'level': 'B2', 'words': '2k - 3k words',   'color': const Color(0xFFD96C06)},
    {'level': 'C1', 'words': '3k - 4k words',   'color': const Color(0xFFFF5722)},
    {'level': 'C2', 'words': '4k - 5k words',   'color': const Color(0xFFE91E63)},
  ];

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_onLangChanged);
    _loadProgress();
  }

  void _onLangChanged() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = languageNotifier.value.code;
    final updated = <String, double>{};

    for (final level in _levels) {
      final key   = 'progress_${langCode}_$level';
      final saved = prefs.getString(key);
      if (saved == null || saved.isEmpty) {
        updated[level] = 0;
        continue;
      }
      final parts = saved.split(',');
      final total = parts.length * 3;
      if (total == 0) { updated[level] = 0; continue; }
      final done  = parts.fold<int>(0, (s, p) => s + (int.tryParse(p) ?? 0));
      updated[level] = (done / total * 100).clamp(0, 100);
    }

    if (mounted) setState(() => _realProgress.addAll(updated));
  }

  @override
  void dispose() {
    languageNotifier.removeListener(_onLangChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? const Color(0xFF090E1A) : const Color(0xFFF5F7FB);
    final cardColor  = isDark ? const Color(0xFF151922) : Colors.white;
    final textColor  = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor   = isDark ? const Color(0xFF8B90A0) : const Color(0xFF9CA3AF);
    final borderColor = isDark ? Colors.transparent : Colors.grey.shade200;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
            child: Column(
              children: [
                verticalSpace(8),

                // عنوان
                SizedBox(
                  width: 290.w,
                  child: ValueListenableBuilder<LanguageInfo>(
                    valueListenable: languageNotifier,
                    builder: (_, __, ___) => Text(
                      S.get('select_level'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),

                verticalSpace(20),

                // قائمة المستويات
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 4,
                    radius: Radius.circular(8.r),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final item       = categories[index];
                        final isSelected = selectedIndex == index;
                        final level      = item['level'] as String;
                        final progress   = _realProgress[level] ?? 0.0;
                        final hasProgress = progress > 0;

                        return GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : borderColor,
                                width: 1.5,
                              ),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // أيقونة المستوى
                                    Container(
                                      width: 46.w,
                                      height: 32.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: item['color'],
                                        borderRadius: BorderRadius.circular(11.r),
                                      ),
                                      child: Text(
                                        level,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 14.w),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['words'],
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (hasProgress)
                                            Text(
                                              '${progress.toStringAsFixed(0)}% completed',
                                              style: TextStyle(
                                                color: item['color'] as Color,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // نسبة التقدم
                                    if (hasProgress)
                                      Padding(
                                        padding: EdgeInsets.only(right: 10.w),
                                        child: Text(
                                          '${progress.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: subColor,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                    // checkbox
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: 28.w,
                                      height: 28.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        color: isSelected
                                            ? const Color(0xFF2563EB)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF2563EB)
                                              : isDark
                                                  ? const Color(0xFF4A5672)
                                                  : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Icon(Icons.check,
                                              color: Colors.white, size: 18.sp)
                                          : null,
                                    ),
                                  ],
                                ),

                                // شريط التقدم
                                if (hasProgress) ...[
                                  SizedBox(height: 10.h),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      minHeight: 4.h,
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          item['color'] as Color),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                verticalSpace(8),

                Text(
                  "5,000 words cover 97% of the English language",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                verticalSpace(16),

                LinearButton(
                  text: S.get('continue'),
                  width: double.infinity,
                  height: 56.h,
                  radius: 18.r,
                  onPressed: () {
                    if (selectedIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Please select a level"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreStartScreen(
                          selectedCategory: categories[selectedIndex!],
                        ),
                      ),
                    );
                  },
                ),

                verticalSpace(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
