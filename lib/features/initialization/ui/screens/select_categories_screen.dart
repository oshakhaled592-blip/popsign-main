import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/language_notifier.dart';
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
    _loadCurrentLevel();
  }

  Future<void> _loadCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('userLevel');
    if (saved != null && mounted) setState(() => selectedLevel = saved);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  List<Map<String, dynamic>> get categories {
    final w = S.get('words_unit');
    return [
      {'category': 'A1', 'quantity': '1-100 $w', 'color': AppColors.a1Color},
      {'category': 'A2', 'quantity': '101 - 1k $w', 'color': AppColors.a2Color},
      {'category': 'B1', 'quantity': '1k - 2k $w', 'color': AppColors.b1Color},
      {'category': 'B2', 'quantity': '2k - 3k $w', 'color': AppColors.b2Color},
      {'category': 'C1', 'quantity': '3k - 4k $w', 'color': AppColors.c1Color},
      {'category': 'C2', 'quantity': '4k - 5k $w', 'color': AppColors.c2Color},
    ];
  }

  Future<void> saveLevel() async {
    if (selectedLevel == null) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userLevel', selectedLevel!);
      await prefs.setBool('hasSelectedLevel', true);

      if (!mounted) return;

      final nav = Navigator.of(context);
      if (nav.canPop()) {
        // Came from within the app (e.g. profile → levels → selectCategories)
        nav.pop();
      } else {
        // Onboarding: build a proper stack [dashboard, levels] so back works
        nav.pushNamedAndRemoveUntil(Routes.dashboard, (r) => false);
        nav.pushNamed(Routes.levels);
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFF83899F) : Colors.grey.shade600;
    final cardColor = isDark ? const Color(0xFF22252E) : Colors.white;
    final cardBorder = isDark
        ? Colors.transparent
        : Colors.grey.shade200;
    final bgColor = isDark ? const Color(0xFF14161B) : const Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              if (Navigator.canPop(context))
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44.w,
                      height: 44.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: textColor, size: 18.sp),
                    ),
                  ),
                ),

              Text(
                S.get('select_level'),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              verticalSpace(30),

              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => verticalSpace(12),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final isSelected = selectedLevel == item['category'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLevel = item['category'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.withValues(alpha: isDark ? 0.25 : 0.12)
                              : cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.withValues(alpha: 0.6)
                                : cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            horizontalSpace(12),

                            Text(
                              item['quantity'],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Spacer(),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.green : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.green : Colors.grey,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                                  : null,
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
                style: TextStyle(
                  color: subColor,
                  fontSize: 13.sp,
                ),
                textAlign: TextAlign.center,
              ),

              verticalSpace(20),

              LinearButton(
                text: isLoading ? S.get('loading') : S.get('continue'),
                onPressed: (selectedLevel == null || isLoading) ? null : saveLevel,
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
