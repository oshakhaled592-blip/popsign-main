import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/spacing.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/styles.dart';
import '../../../../core/widgets/linear_button.dart';

class StartPageScreen extends StatelessWidget {
  const StartPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF5F7FB);
    final textColor  = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor   = isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              verticalSpace(20),
              Image.asset(
                "assets/images/start-image.png",
                width: 400.w,
                height: 400.h,
                fit: BoxFit.cover,
              ),
              verticalSpace(40),
              Text(
                textAlign: TextAlign.center,
                S.get('learn_lang_title'),
                style: AppTextStyles.font36BoldWhite.copyWith(color: textColor),
              ),
              verticalSpace(16),
              Text(
                textAlign: TextAlign.center,
                S.get('learn_lang_subtitle'),
                style: AppTextStyles.font17RegularGray.copyWith(color: subColor),
              ),
              verticalSpace(40),
              LinearButton(
                text: S.get('get_started'),
                height: 50.h,
                width: 342.w,
                icon: Icons.bolt,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.selectLanguage);
                },
                radius: 12.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
