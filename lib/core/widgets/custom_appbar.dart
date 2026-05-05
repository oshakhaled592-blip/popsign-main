import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/styles.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isBackButton)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),

        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title(context),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(width: 40.w),
      ],
    );
  }
}