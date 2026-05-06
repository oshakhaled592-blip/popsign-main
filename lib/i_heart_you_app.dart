import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routing/routes.dart';
import 'core/routing/app_router.dart';

class IHeartYouApp extends StatelessWidget {
  const IHeartYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          cardColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF22C55E),
          ),
        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1218),
          cardColor: const Color(0xFF151922),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF22C55E),
          ),
        ),

        themeMode: ThemeMode.dark,

        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter().generateRoute,
      ),
    );
  }
}
