import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helpers/extension.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/quiz_step_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class StudyTimeScreen extends StatefulWidget {
  const StudyTimeScreen({super.key});

  @override
  State<StudyTimeScreen> createState() => _StudyTimeScreenState();
}

class _StudyTimeScreenState extends State<StudyTimeScreen> {
  final List<int> markers = const [5, 10, 15, 30];
  double selectedMinutes = 10;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? Colors.white60 : AppColors.grayTextLight;

    return QuizScaffold(
      step: 5,
      totalSteps: 5,
      buttonText: S.get('continue'),
      onContinue: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('onb_minutesPerDay', selectedMinutes.round());
        if (context.mounted) context.pushNamed(Routes.signup);
      },
      child: Column(
        children: [
          QuestionHeader(
            emoji: '⏰',
            title: S.get('study_time_title'),
          ),
          verticalSpace(40),
          Text(
            '${selectedMinutes.round()} ${S.get('min_per_day')}',
            style: TextStyle(
              color: quizAccent,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          verticalSpace(20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11.r),
            ),
            child: Slider(
              value: selectedMinutes,
              min: 5,
              max: 30,
              divisions: 5,
              activeColor: quizAccent,
              inactiveColor: isDark ? Colors.white24 : Colors.grey.shade300,
              onChanged: (v) => setState(() => selectedMinutes = v),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: markers
                  .map((m) => Text(
                        '$m ${S.get('min_short')}',
                        style: TextStyle(color: subColor, fontSize: 12.sp),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
