import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/theme/styles.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpace(20),

                Image.asset(
                  "assets/images/start-image.png",
                  width: 400.w,
                  height: 400.h,
                  fit: BoxFit.contain,
                ),

                verticalSpace(30),

                Text(
                  "Learn a Language easily with Cards",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title(context).copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                verticalSpace(14),

                Text(
                  "Learn words using cards,\nchoosing levels that are convenient for you",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small(context).copyWith(
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
                    Navigator.pushNamed(context, Routes.selectLanguage);
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
