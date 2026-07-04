import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/spacing.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/linear_button.dart';

class StartPageScreen extends StatelessWidget {
  const StartPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor  = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor   = isDark ? AppColors.grayText : AppColors.grayTextLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpace(20),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    maxWidth: double.infinity,
                  ),
                  child: Image.asset(
                    "assets/images/start-image.png",
                    fit: BoxFit.contain,
                  ),
                ),
                verticalSpace(40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    textAlign: TextAlign.center,
                    S.get('learn_lang_title'),
                    style: AppTextStyles.font36BoldWhite.copyWith(color: textColor),
                  ),
                ),
                verticalSpace(16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    textAlign: TextAlign.center,
                    S.get('learn_lang_subtitle'),
                    style: AppTextStyles.font17RegularGray.copyWith(color: subColor),
                  ),
                ),
                verticalSpace(40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: LinearButton(
                    text: S.get('get_started'),
                    height: 50.h,
                    width: double.infinity,
                    icon: Icons.bolt,
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.selectLanguage);
                    },
                    radius: 12.r,
                  ),
                ),
                verticalSpace(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
