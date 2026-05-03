import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/theme/styles.dart';
import 'package:popsign/core/widgets/linear_button.dart';
import 'package:popsign/core/theme/app_colors.dart';

import 'pre_start_screen.dart';

class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<SelectCategoriesScreen> createState() =>
      _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState
    extends State<SelectCategoriesScreen> {
  final List<Map<String, dynamic>> categories = [
    {'category': 'A1', 'quantity': '1-100 words', 'color': AppColors.a1Color},
    {'category': 'A2', 'quantity': '101 - 1k words', 'color': AppColors.a2Color},
    {'category': 'B1', 'quantity': '1k - 2k words', 'color': AppColors.b1Color},
    {'category': 'B2', 'quantity': '2k - 3k words', 'color': AppColors.b2Color},
    {'category': 'C1', 'quantity': '3k - 4k words', 'color': AppColors.c1Color},
    {'category': 'C2', 'quantity': '4k - 5k words', 'color': AppColors.c2Color},
  ];

  /// selected categories
  final Set<int> selectedIndexes = {};

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void goToNext() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PreStartScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
          final slide = Tween(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select categories for\nlearning language',
                textAlign: TextAlign.center,
                style: AppTextStyles.font24BoldWhite,
              ),

              verticalSpace(30),

              SizedBox(
                height: categories.length * 12.h +
                    categories.length * 60.h,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      verticalSpace(12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected =
                        selectedIndexes.contains(index);

                    return GestureDetector(
                      onTap: () => toggleSelection(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkGray.withValues(alpha: 0.9)
                              : AppColors.darkGray,
                          borderRadius: BorderRadius.circular(16.r),
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                )
                              : null,
                        ),
                        width: double.infinity,
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
                                borderRadius:
                                    BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                categories[index]['category'],
                                style:
                                    AppTextStyles.font16boldWhite,
                              ),
                            ),

                            horizontalSpace(12),

                            Text(
                              categories[index]['quantity'],
                              style:
                                  AppTextStyles.font18RegularWhite,
                            ),

                            const Spacer(),

                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                toggleSelection(index);
                              },
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                            ),
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

              const Spacer(),

              LinearButton(
                text: "Continue",
                width: double.infinity.w,
                radius: 12.r,
                onPressed: selectedIndexes.isEmpty
                    ? null
                    : goToNext,
              ),

              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }
}