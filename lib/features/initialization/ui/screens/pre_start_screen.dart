import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/data/word_data.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:popsign/core/widgets/linear_button.dart';
import 'word_list_screen.dart';

class PreStartScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedCategory;

  const PreStartScreen({super.key, this.selectedCategory});

  @override
  State<PreStartScreen> createState() => _PreStartScreenState();
}

class _PreStartScreenState extends State<PreStartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade  = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  String get _level => widget.selectedCategory?['level'] as String? ?? 'A1';

  static const _levelColors = {
    'A1': [Color(0xFF0BA58D), Color(0xFF1EC9B4)],
    'A2': [Color(0xFF5E9E10), Color(0xFF83D61B)],
    'B1': [Color(0xFF9E8010), Color(0xFFD4AC0D)],
    'B2': [Color(0xFFB85A05), Color(0xFFD96C06)],
    'C1': [Color(0xFFDD4511), Color(0xFFFF5722)],
    'C2': [Color(0xFFC2185B), Color(0xFFE91E63)],
  };

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? const Color(0xFF0B0F18) : const Color(0xFFF2F4FA);
    final cardBg    = isDark ? const Color(0xFF141A29) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg     = isDark ? const Color(0xFF1E2538) : Colors.white;
    final btnIcon   = isDark ? Colors.white70 : const Color(0xFF1A1A2E);
    final divColor  = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade200;

    final colors = _levelColors[_level] ?? _levelColors['A1']!;
    final words  = getWords(languageNotifier.value.code, _level);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.pushNamed(context, Routes.chatScreen),
        child: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.smart_toy_rounded,
              color: const Color(0xFF1A1A2E),
              size: 30.sp,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconBtn(Icons.arrow_back_ios_new_rounded,
                          bg: btnBg, iconColor: btnIcon,
                          onTap: () => Navigator.pop(context)),

                      Text(
                        S.get('pre_start'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _iconBtn(Icons.menu_rounded,
                          bg: btnBg, iconColor: btnIcon,
                          onTap: () => Navigator.pushNamed(context, Routes.profile)),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            _level,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${words.length} words',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              const {
                                'A1': '1 – 100 words',
                                'A2': '101 – 1k words',
                                'B1': '1k – 2k words',
                                'B2': '2k – 3k words',
                                'C1': '3k – 4k words',
                                'C2': '4k – 5k words',
                              }[_level] ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    physics: const BouncingScrollPhysics(),
                    itemCount: words.length,
                    separatorBuilder: (context, index) => Divider(height: 1.h, color: divColor),
                    itemBuilder: (_, i) {
                      return Container(
                        color: cardBg,
                        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32.w,
                              child: Text(
                                (i + 1).toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: subColor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                words[i],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 12.h),
                  child: Column(
                    children: [
                      LinearButton(
                        text: S.get('start_learning'),
                        icon: Icons.auto_stories_rounded,
                        width: double.infinity,
                        height: 54.h,
                        radius: 16.r,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordListScreen(level: _level),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: 120.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon,
      {required Color bg, required Color iconColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
    );
  }
}