import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _current = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.selectLanguage);
  }

  void _next() {
    if (_current < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor = isDark ? Colors.white54 : AppColors.grayTextLight;
    const accent = AppColors.success;
    final isLast = _current == 1;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(2, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 6.w),
                        width: i == _current ? 28.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? accent
                              : (isDark
                                  ? Colors.white24
                                  : Colors.black.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: _finish,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        S.get('skip'),
                        style: TextStyle(
                          color: subColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _current = i),
                children: [
                  _Page1(
                    isDark: isDark,
                    textColor: textColor,
                    subColor: subColor,
                    floatAnim: _floatAnim,
                  ),
                  _Page2(
                    isDark: isDark,
                    textColor: textColor,
                    subColor: subColor,
                    floatAnim: _floatAnim,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 36.h),
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 20.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isLast ? S.get('get_started') : S.get('next'),
                        key: ValueKey(isLast),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final Animation<double> floatAnim;

  const _Page1({
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.success;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, floatAnim.value),
              child: child,
            ),
            child: SizedBox(
              height: 260.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: isDark ? 0.08 : 0.07),
                    ),
                  ),

                  Positioned(
                    top: 20.h,
                    child: Container(
                      width: 190.w,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 22.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF171D2E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: isDark ? 0.4 : 0.1),
                            blurRadius: 24.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'A1 Level',
                              style: TextStyle(
                                color: accent,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Hello',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '[həˈloʊ]',
                            style: TextStyle(
                              color: subColor,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: accent),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      S.get('i_know'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Container(
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      S.get('learn'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 12.r,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 18.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1F35)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8.r,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: subColor,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 44.h),

          Text(
            S.get('flashcards_title'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            S.get('flashcards_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subColor,
              fontSize: 14.sp,
              height: 1.65,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _Page2 extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final Animation<double> floatAnim;

  const _Page2({
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
    const purple = AppColors.accent;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, floatAnim.value),
              child: child,
            ),
            child: SizedBox(
              height: 260.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: purple.withValues(alpha: isDark ? 0.08 : 0.07),
                    ),
                  ),

                  Image.asset(
                    'assets/images/start-image.png',
                    height: 220.h,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 44.h),

          Text(
            S.get('translate_sign_title'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            S.get('translate_sign_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subColor,
              fontSize: 14.sp,
              height: 1.65,
            ),
          ),
        ],
        ),
      ),
    );
  }
}
