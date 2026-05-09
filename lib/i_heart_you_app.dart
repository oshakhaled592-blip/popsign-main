import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/routing/routes.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_notifier.dart';

class IHeartYouApp extends StatelessWidget {
  const IHeartYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, __) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, themeMode, __) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
          ));
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _lightTheme(),
            darkTheme: _darkTheme(),
            themeMode: themeMode,
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter().generateRoute,
          );
        },
      ),
    );
  }

  ThemeData _lightTheme() {
    final base = ThemeData.light(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      cardColor: AppColors.lightCard,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.lightCard,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.poppins(
            color: const Color(0xFF1A1A2E), fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.poppins(color: const Color(0xFF4B5563)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        titleTextStyle: GoogleFonts.poppins(
          color: const Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
      ),
      dividerColor: AppColors.lightBorder,
    );
  }

  ThemeData _darkTheme() {
    final base = ThemeData.dark(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      cardColor: AppColors.darkCard,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.darkCard,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.poppins(color: Colors.white70),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      ),
      dividerColor: AppColors.darkBorder,
    );
  }
}
