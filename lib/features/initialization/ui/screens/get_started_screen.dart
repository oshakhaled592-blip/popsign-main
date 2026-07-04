import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/theme/styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/linear_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpace(20),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.42,
                    maxWidth: double.infinity,
                  ),
                  child: Image.asset(
                    "assets/images/start-image.png",
                    fit: BoxFit.contain,
                  ),
                ),

                verticalSpace(30),

                Text(
                  S.get('learn_lang_title'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font24BoldWhite.copyWith(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                verticalSpace(14),

                Text(
                  S.get('learn_lang_subtitle'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font13RegularGray.copyWith(
                    color: isDark ? AppColors.grayText : AppColors.grayTextLight,
                    height: 1.5,
                    fontSize: 15.sp,
                  ),
                ),

                const Spacer(),

                LinearButton(
                  text: S.get('get_started'),
                  height: 55.h,
                  width: double.infinity,
                  icon: Icons.bolt,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.selectLanguage,
                    );
                  },
                  radius: 16.r,
                ),

                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}