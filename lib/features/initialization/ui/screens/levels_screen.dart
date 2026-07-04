import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:popsign/core/helpers/level_helper.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/theme/app_colors.dart';
import 'pre_start_screen.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  static const _levelColors = {
    'A1': AppColors.a1Color,
    'A2': AppColors.a2Color,
    'B1': AppColors.b1Color,
    'B2': AppColors.b2Color,
    'C1': AppColors.c1Color,
    'C2': AppColors.c2Color,
  };

  static String _levelDesc(String level) {
    final w = S.get('words_unit');
    return {
      'A1': '1 – 100 $w',
      'A2': '101 – 1k $w',
      'B1': '1k – 2k $w',
      'B2': '2k – 3k $w',
      'C1': '3k – 4k $w',
      'C2': '4k – 5k $w',
    }[level] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor = isDark ? Colors.white54 : Colors.grey.shade500;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.get('levels_title'),
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20.sp),
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(S.get('no_user_data'), style: TextStyle(color: textColor)),
            );
          }

          final userLevel = snapshot.data!.getString('userLevel') ?? 'A1';

          return SafeArea(
            top: false,
            child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: allLevels.length,
            separatorBuilder: (context, i) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final level = allLevels[index];
              final unlocked = isUnlocked(level, userLevel);
              final color = _levelColors[level] ?? AppColors.a1Color;

              return GestureDetector(
                onTap: unlocked
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PreStartScreen(
                              selectedCategory: {'level': level},
                            ),
                          ),
                        )
                    : null,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: unlocked
                          ? color.withValues(alpha: 0.4)
                          : Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 36.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: unlocked ? color : Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level,
                              style: TextStyle(
                                color: unlocked ? textColor : subColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _levelDesc(level),
                              style: TextStyle(color: subColor, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                        color: unlocked ? color : Colors.grey.shade500,
                        size: 22.sp,
                      ),
                    ],
                  ),
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }
}
