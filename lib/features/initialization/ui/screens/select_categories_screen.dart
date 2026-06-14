import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/theme/styles.dart';
import 'package:popsign/core/widgets/linear_button.dart';

import '../../../../core/theme/app_colors.dart';

class SelectCategoriesScreen extends StatelessWidget {
  const SelectCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'category': 'A1', 'quantity': '1-100 words', 'color': AppColors.a1Color},
      {
        'category': 'A2',
        'quantity': '101 - 1k words',
        'color': AppColors.a2Color,
      },
      {
        'category': 'B1',
        'quantity': '1k - 2k words',
        'color': AppColors.b1Color,
      },
      {
        'category': 'B2',
        'quantity': '2k - 3k words',
        'color': AppColors.b2Color,
      },
      {
        'category': 'C1',
        'quantity': '3k - 4k words',
        'color': AppColors.c1Color,
      },
      {
        'category': 'C2',
        'quantity': '4k - 5k words',
        'color': AppColors.c2Color,
      },
    ];
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                'Select categories for\nlearning language',
                style: AppTextStyles.font24BoldWhite,
              ),
              verticalSpace(30),
              SizedBox(
                height: categories.length * 12.h + categories.length * 60.h,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => verticalSpace(12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        //! Handle category selection
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkGray,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        width: double.infinity.w,
                        height: 60.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 17.w,
                          vertical: 17.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36.w,
                              height: 28.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: categories[index]['color'],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                categories[index]['category'],
                                style: AppTextStyles.font16boldWhite,
                              ),
                            ),

                            horizontalSpace(12),
                            Text(
                              categories[index]['quantity'],
                              style: AppTextStyles.font18RegularWhite,
                            ),
                            Spacer(),
                            Checkbox(value: false, onChanged: (iscompleted) {}),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              verticalSpace(10),
              Text(
                '5,000 words cover 97% of the English language',
                style: AppTextStyles.font13RegularWhiteInter,
              ),
              Spacer(),
              LinearButton(
                text: "Continue",
                onPressed: () {},
                width: double.infinity.w,
                radius: 12.r,
              ),
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }
}
