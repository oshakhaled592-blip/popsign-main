import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

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
            colors: [AppColors.gradient1, AppColors.gradient2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
