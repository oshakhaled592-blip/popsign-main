import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:popsign/core/theme/styles.dart';
import 'package:popsign/core/widgets/linear_button.dart';
import '../../../../core/theme/app_colors.dart';


class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<SelectCategoriesScreen> createState() =>
      _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  String? selectedLevel;
  bool isLoading = false;

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

  final List<Map<String, dynamic>> categories = [
    {'category': 'A1', 'quantity': '1-100 words', 'color': AppColors.a1Color},
    {'category': 'A2', 'quantity': '101 - 1k words', 'color': AppColors.a2Color},
    {'category': 'B1', 'quantity': '1k - 2k words', 'color': AppColors.b1Color},
    {'category': 'B2', 'quantity': '2k - 3k words', 'color': AppColors.b2Color},
    {'category': 'C1', 'quantity': '3k - 4k words', 'color': AppColors.c1Color},
    {'category': 'C2', 'quantity': '4k - 5k words', 'color': AppColors.c2Color},
  ];

  Future<void> saveLevel() async {
    if (selectedLevel == null) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userLevel', selectedLevel!);
      await prefs.setBool('hasSelectedLevel', true);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.get('error_prefix')}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              Text(
                S.get('select_level'),
                style: AppTextStyles.font24BoldWhite,
                textAlign: TextAlign.center,
              ),

              verticalSpace(30),

              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => verticalSpace(12),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final isSelected =
                        selectedLevel == item['category'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLevel = item['category'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.withValues(alpha: 0.3)
                              : AppColors.darkGray,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        height: 60.h,
                        padding: EdgeInsets.symmetric(horizontal: 17.w),
                        child: Row(
                          children: [
                            Container(
                              width: 36.w,
                              height: 28.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                item['category'],
                                style: AppTextStyles.font16boldWhite,
                              ),
                            ),

                            horizontalSpace(12),

                            Text(
                              item['quantity'],
                              style: AppTextStyles.font18RegularWhite,
                            ),

                            const Spacer(),

                            Checkbox(
                              value: isSelected,
                              onChanged: (_) {
                                setState(() {
                                  selectedLevel = item['category'];
                                });
                              },
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
                S.get('words_coverage_note'),
                style: AppTextStyles.font13RegularWhiteInter,
              ),

              verticalSpace(20),

              LinearButton(
                text: isLoading ? S.get('loading') : S.get('continue'),
                onPressed:
                    (selectedLevel == null || isLoading)
                        ? null
                        : saveLevel,
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