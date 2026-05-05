import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/styles.dart';

class LinearButton extends StatelessWidget {
  final IconData? icon;
  final double? radius;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final String text;

  const LinearButton({
    super.key,
    this.icon,
    this.radius,
    this.width,
    this.height,
    this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 54.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.gradient1,
              AppColors.gradient2,
            ],
          ),
          borderRadius: BorderRadius.circular(radius ?? 30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, color: Colors.white),

            if (icon != null) SizedBox(width: 6.w),

            Text(
              text,
              style: AppTextStyles.button(context),
            ),
          ],
        ),
      ),
    );
  }
}