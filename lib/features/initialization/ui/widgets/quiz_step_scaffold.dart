import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';

const Color quizAccent = AppColors.accent;

class QuizScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final Widget child;
  final String buttonText;
  final VoidCallback? onContinue;
  final bool showBack;

  const QuizScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.child,
    required this.onContinue,
    this.buttonText = 'Continue',
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final btnBgColor = isDark ? const Color(0xFF181830) : Colors.white;
    final trackColor =
        isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.1);
    final disabled = onContinue == null;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showBack)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: btnBgColor,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18.sp, color: textColor),
                      ),
                    ),
                  SizedBox(width: showBack ? 14.w : 0),
                  Expanded(
                    child: Row(
                      children: List.generate(totalSteps, (i) {
                        final filled = i <= step - 1;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                right: i == totalSteps - 1 ? 0 : 6.w),
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: filled ? quizAccent : trackColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              verticalSpace(28),
              Expanded(child: SingleChildScrollView(child: child)),
              verticalSpace(16),
              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: disabled
                      ? (isDark ? Colors.white12 : Colors.grey.shade300)
                      : quizAccent,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: disabled
                      ? []
                      : [
                          BoxShadow(
                            color: quizAccent.withValues(alpha: 0.35),
                            blurRadius: 20.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: onContinue,
                    child: Center(
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: disabled
                              ? (isDark ? Colors.white38 : Colors.grey.shade500)
                              : Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              verticalSpace(8),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;

  const QuestionHeader({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor = isDark ? Colors.white60 : AppColors.grayTextLight;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Column(
      children: [
        Container(
          width: 84.w,
          height: 84.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: quizAccent.withValues(alpha: isDark ? 0.18 : 0.12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: TextStyle(fontSize: 38.sp)),
        ),
        verticalSpace(20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
            border: isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                : null,
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (subtitle != null) ...[
                verticalSpace(8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subColor, fontSize: 13.sp, height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class QuizOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor = isDark ? Colors.white60 : AppColors.grayTextLight;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected
                ? quizAccent
                : (isDark ? const Color(0xFF263047) : Colors.grey.shade300),
            width: selected ? 2.w : 1.2.w,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: quizAccent.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: quizAccent, size: 19.sp),
              ),
              horizontalSpace(14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(subtitle!,
                        style: TextStyle(color: subColor, fontSize: 12.sp)),
                  ],
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? quizAccent : Colors.transparent,
                border: Border.all(
                    color: selected
                        ? quizAccent
                        : (isDark ? const Color(0xFF263047) : Colors.grey.shade300),
                    width: 1.5.w),
              ),
              child: selected
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
