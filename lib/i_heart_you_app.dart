import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routing/routes.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_notifier.dart';

class IHeartYouApp extends StatelessWidget {
  const IHeartYouApp({super.key});

  // This is a phone-first UI. On a laptop/desktop/web window we let content
  // fill the full real width (no boxed/letterboxed look at all), but text
  // and spacing must NOT scale linearly with that real width or a 1920px
  // window balloons everything ~5x. So we keep ScreenUtil's scale factor
  // pinned to what it would be on an actual _scaleReferenceWidth-wide
  // device, independent of how wide the real window actually is.
  static const double _scaleReferenceWidth = 600;
  static const double _scaleReferenceHeight = 1300;
  static const double _wideScreenBreakpoint = 600;
  static const Size _baseDesignSize = Size(390, 844);

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FF),
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
    return LayoutBuilder(
      builder: (context, _) {
        final windowSize = MediaQuery.sizeOf(context);
        final isWideScreen = windowSize.width > _wideScreenBreakpoint;

        // flutter_screenutil always scales against the *real* physical
        // window size. Past our breakpoint we inflate designSize by the
        // ratio between the real window and our scale reference, which pins
        // the effective scale factor at what it would be on an actual
        // _scaleReferenceWidth-wide device — instead of growing without
        // bound on a 1920px-wide laptop window.
        final designSize = isWideScreen
            ? Size(
                _baseDesignSize.width * (windowSize.width / _scaleReferenceWidth),
                _baseDesignSize.height * (windowSize.height / _scaleReferenceHeight),
              )
            : _baseDesignSize;

        return ScreenUtilInit(
          designSize: designSize,
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
      },
    );
  }
}
