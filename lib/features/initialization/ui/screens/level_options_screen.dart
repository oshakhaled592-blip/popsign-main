import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helpers/extension.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/quiz_step_scaffold.dart';

class LevelOptionsScreen extends StatefulWidget {
  const LevelOptionsScreen({super.key});

  @override
  State<LevelOptionsScreen> createState() => _LevelOptionsScreenState();
}

class _LevelOptionsScreenState extends State<LevelOptionsScreen> {
  String? selectedLevel;

  final List<Map<String, dynamic>> levels = const [
    {'code': 'A1', 'nameKey': 'level_beginner', 'color': AppColors.a1Color},
    {'code': 'A2', 'nameKey': 'level_elementary', 'color': AppColors.a2Color},
    {'code': 'B1', 'nameKey': 'level_intermediate', 'color': AppColors.b1Color},
    {'code': 'B2', 'nameKey': 'level_upper_intermediate', 'color': AppColors.b2Color},
    {'code': 'C1', 'nameKey': 'level_advanced', 'color': AppColors.c1Color},
    {'code': 'C2', 'nameKey': 'level_proficient', 'color': AppColors.c2Color},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white60 : const Color(0xFF9CA3AF);
    final cardColor = isDark ? const Color(0xFF131A2C) : Colors.white;

    return QuizScaffold(
      step: 4,
      totalSteps: 5,
      buttonText: S.get('continue'),
      onContinue: selectedLevel == null
          ? null
          : () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('onb_level', selectedLevel!);
              if (context.mounted) context.pushNamed(Routes.studyTime);
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.get('your_level_title'),
            style: TextStyle(
              color: textColor,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          verticalSpace(20),
          Expanded(
            child: ListView.separated(
              itemCount: levels.length,
              separatorBuilder: (context, index) => verticalSpace(12),
              itemBuilder: (context, index) {
                final lvl = levels[index];
                final isSelected = selectedLevel == lvl['code'];

                return GestureDetector(
                  onTap: () =>
                      setState(() => selectedLevel = lvl['code'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isSelected
                            ? quizAccent
                            : (isDark
                                ? const Color(0xFF263047)
                                : Colors.grey.shade300),
                        width: isSelected ? 2 : 1.2,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 34.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: lvl['color'] as Color,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            lvl['code'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        horizontalSpace(14),
                        Expanded(
                          child: Text(
                            S.get(lvl['nameKey'] as String),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? quizAccent : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? quizAccent : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check,
                                  color: Colors.white, size: 14.sp)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          verticalSpace(8),
          Text(
            S.get('level_not_sure_note'),
            style: TextStyle(color: subColor, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
