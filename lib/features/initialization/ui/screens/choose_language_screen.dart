import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/extension.dart';
import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/styles.dart';
import 'package:popsign/core/widgets/linear_button.dart';
import 'package:popsign/features/initialization/ui/widgets/language_selected_list.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_appbar.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  int? selectedLanguageIndex;

  final List<Map<String, String>> languages = [
    {'name': "Arabic", 'flag': '🇸🇦'},
    {"name": "English", "flag": '🇺🇸'},
    {"name": "French", "flag": '🇫🇷'},
    {"name": "Spanish", "flag": '🇪🇸'},
    {"name": "German", "flag": '🇩🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(
                title: 'What language are you want to study?',
                isBackButton: true,
              ),
              verticalSpace(20),
              LanguageSelectList(
                languages: languages,
                selectedLanguageIndex: selectedLanguageIndex,
                onLanguageSelected: (index) {
                  setState(() {
                    selectedLanguageIndex = selectedLanguageIndex == index
                        ? null
                        : index;
                  });
                },
              ),
              Spacer(),
              LinearButton(
                text: "Continue",
                radius: 12.r,
                width: double.infinity,
                onPressed: () {
                  if (selectedLanguageIndex == null) {
                    showCustomSnackBar(
                      context,
                      "Please select a language to continue.",
                      Colors.red,
                    );
                  } else {
                    context.pushNamedAndRemoveUntil(
                      Routes.selectCategories,
                      predicate: (route) => false,
                    );
                  }
                },
              ),
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }
}

void showCustomSnackBar(
  BuildContext context,
  String message,
  Color backgroundColor,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          message,
          style: AppTextStyles.font18RegularWhiteInter.copyWith(fontSize: 14),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 40.h),
    ),
  );
}
