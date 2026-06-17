// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../../../core/theme/styles.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '$text ',
            style: AppTextStyles.font13Lightpink,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(actionText, style: AppTextStyles.font13RegularDarkpink),
        ),
      ],
    );
  }
}
