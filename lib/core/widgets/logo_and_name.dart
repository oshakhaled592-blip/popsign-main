import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/styles.dart';

class LogoAndName extends StatelessWidget {
  const LogoAndName({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SvgPicture.asset(
          'assets/svgs/app-logo.svg',
          height: 81.39.h,
          width: 67.45.w,
        ),
        Text(
          "I Hear You",
          style: AppTextStyles.font36SemiboldWhite.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

