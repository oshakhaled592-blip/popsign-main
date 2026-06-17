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
    return Scaffold(
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
                    color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    color: const Color(0xFF22C55E),
                    size: 44.sp,
                  ),
                ),
              ),

              verticalSpace(28),

              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: AppTextStyles.font24BoldWhite,
              ),

              verticalSpace(12),

              Text(
                "We've sent a verification link to\n$email\n\nPlease check your inbox and verify your account before logging in.",
                textAlign: TextAlign.center,
                style: AppTextStyles.font13RegularWhite,
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
