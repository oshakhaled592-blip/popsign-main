import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/theme/app_colors.dart';
import 'package:popsign/core/theme/styles.dart';

class LanguageSelectList extends StatelessWidget {
  const LanguageSelectList({
    super.key,
    required this.languages,
    required this.selectedLanguageIndex,
    required this.onLanguageSelected,
  });

  final List<Map<String, String>> languages;
  final int? selectedLanguageIndex;
  final Function(int) onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          languages.length * 12.h * 2 +
          languages.length * 12.h * 2 +
          languages.length * 48.h,
      child: ListView.separated(
        // shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: languages.length,
        separatorBuilder: (context, index) => verticalSpace(10),
        itemBuilder: (context, index) {
          final isSelected = selectedLanguageIndex == index;
          return GestureDetector(
            onTap: () => onLanguageSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGray : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.darkGray, width: 2.w),
              ),
              child: Row(
                children: [
                  Text(
                    languages[index]['flag']!,
                    style: AppTextStyles.font24BoldWhite,
                  ),
                  horizontalSpace(16),
                  Text(
                    languages[index]['name']!,
                    style: AppTextStyles.font18RegularWhiteInter.copyWith(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
