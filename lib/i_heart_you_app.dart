import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routing/routes.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_notifier.dart';

class IHeartYouApp extends StatelessWidget {
  const IHeartYouApp({super.key});

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF2F4FA),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.linear1,
      brightness: Brightness.light,
      primary: AppColors.linear1,
    ),
    useMaterial3: true,
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.linear2,
      brightness: Brightness.dark,
      primary: AppColors.linear2,
    ),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      // splitScreenMode: true,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'I hear you',
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: mode,
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter().generateRoute,
          );
        },
      ),
    );
  }
}
