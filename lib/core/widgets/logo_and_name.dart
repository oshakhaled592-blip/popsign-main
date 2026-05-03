import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/styles.dart';

class LogoAndName extends StatelessWidget {
  final bool compact;
  const LogoAndName({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/Logo.png',
          height: compact ? 38.h : 90.h,
          errorBuilder: (_, __, ___) => Icon(
            Icons.hearing,
            size: compact ? 38.h : 90.h,
            color: Colors.white,
          ),
        ),
        SizedBox(width: compact ? 10.w : 14.w),
        Text(
          "I Hear You",
          style: compact
              ? AppTextStyles.font18BoldWhite
              : AppTextStyles.font36SemiboldWhite,
        ),
      ],
    );
  }
}
