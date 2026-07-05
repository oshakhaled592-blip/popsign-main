import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:popsign/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();

      final langCode = prefs.getString('langCode');
      final langName = prefs.getString('langName');
      final langFlag = prefs.getString('langFlag');
      if (langCode != null && langName != null && langFlag != null) {
        languageNotifier.value =
            LanguageInfo(name: langName, flag: langFlag, code: langCode);
      }

      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (!mounted) return;
      if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      } else if (!isLoggedIn) {
        Navigator.pushReplacementNamed(context, Routes.login);
      } else {
        final hasChosenLanguage = prefs.getString('langCode') != null;
        final destination = !hasChosenLanguage ? Routes.startPage : Routes.dashboard;
        Navigator.pushReplacementNamed(context, destination);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textCol  = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subCol   = isDark ? Colors.white38 : AppColors.grayTextLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  width: 100.w,
                  height: 100.w,
                  errorBuilder: (ctx, err, stack) => Icon(
                    Icons.hearing,
                    color: textCol,
                    size: 80.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  S.get('app_name'),
                  style: TextStyle(
                    color: textCol,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  S.get('splash_tagline'),
                  style: TextStyle(
                    color: subCol,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 60.h),
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
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
}
