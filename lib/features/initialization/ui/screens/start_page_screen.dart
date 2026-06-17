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
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
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
                style: AppTextStyles.font36BoldWhite,
              ),
              verticalSpace(16),
              Text(
                textAlign: TextAlign.center,
                S.get('learn_lang_subtitle'),
                style: AppTextStyles.font17RegularGray,
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
