import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/extension.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/linear_button.dart';

class CheckEmailScreen extends StatelessWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor  = isDark ? Colors.white60 : AppColors.grayTextLight;
    const accent    = AppColors.success;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 90.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    color: accent,
                    size: 44.sp,
                  ),
                ),
              ),

              verticalSpace(28),

              Text(
                S.get('verify_email_title'),
                textAlign: TextAlign.center,
                style: AppTextStyles.font24BoldWhite.copyWith(color: textColor),
              ),

              verticalSpace(12),

              Text(
                S.get('verify_email_body').replaceAll('{email}', email),
                textAlign: TextAlign.center,
                style: AppTextStyles.font13RegularWhite.copyWith(color: subColor),
              ),

              verticalSpace(36),

              LinearButton(
                text: S.get('go_to_login'),
                onPressed: () {
                  context.pushNamedAndRemoveUntil(
                    Routes.login,
                    predicate: (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
