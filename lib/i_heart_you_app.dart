import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routing/routes.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';

class IHeartYouApp extends StatelessWidget {
  const IHeartYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      // splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'I hear you',
        theme: ThemeData(scaffoldBackgroundColor: AppColors.darkBackground),
        initialRoute: Routes.login,
        onGenerateRoute: AppRouter().generateRoute,
      ),
    );
  }
}
