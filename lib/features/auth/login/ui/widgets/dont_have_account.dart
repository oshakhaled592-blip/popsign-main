import 'package:flutter/material.dart';
import '../../../../../core/theme/styles.dart';

class DontHaveAccount extends StatelessWidget {
  const DontHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: AppTextStyles.small(context),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/signup");
          },
          child: Text(
            "Sign up",
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}