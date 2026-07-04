// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../../../core/theme/styles.dart';
import '../../../../../core/theme/app_colors.dart';

class DontHaveAccount extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;
  const DontHaveAccount({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '$text ',
            style: AppTextStyles.font13Lightpink.copyWith(
              fontWeight: isDark ? null : FontWeight.w500,
              color: isDark ? null : AppColors.linear1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: AppTextStyles.font13RegularDarkpink,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
