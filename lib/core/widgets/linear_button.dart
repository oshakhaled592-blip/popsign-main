// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/spacing.dart';

import '../theme/app_colors.dart';
import '../theme/styles.dart';

class LinearButton extends StatelessWidget {
  final IconData? icon;
  final double? radius;
  final double? width;
  final double? height;
  final void Function()? onPressed;
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
        alignment: Alignment.center,
        width: width ?? 110.w,
        height: height ?? 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.linear1, AppColors.linear2],
          ),
          borderRadius: BorderRadius.circular(radius ?? 30.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(icon, color: Colors.white, size: 20.sp)
                : SizedBox.shrink(),
            icon != null ? horizontalSpace(5) : SizedBox.shrink(),
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.font14Boldblack.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
