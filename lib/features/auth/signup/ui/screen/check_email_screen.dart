import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/extension.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';

class CheckEmailScreen extends StatelessWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF5F7FB);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white60 : const Color(0xFF6B7280);
    const accent    = Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 35.w),
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
                'Verify your email',
                textAlign: TextAlign.center,
                style: AppTextStyles.font24BoldWhite.copyWith(color: textColor),
              ),

              verticalSpace(12),

              Text(
                "We've sent a verification link to\n$email\n\nPlease check your inbox and verify your account before logging in.",
                textAlign: TextAlign.center,
                style: AppTextStyles.font13RegularWhite.copyWith(color: subColor),
              ),

              verticalSpace(36),

              LinearButton(
                text: 'Go to Login',
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
