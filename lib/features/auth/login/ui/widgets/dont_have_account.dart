// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../../../core/theme/styles.dart';

class DontHaveAccount extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;
  const DontHaveAccount({
    Key? key,
    required this.text,
    required this.actionText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$text ', style: AppTextStyles.font13Lightpink),
        GestureDetector(
          onTap: onTap,
          child: Text(actionText, style: AppTextStyles.font13RegularDarkpink),
        ),
      ],
    );
  }
}
