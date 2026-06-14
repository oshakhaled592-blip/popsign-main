import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:popsign/core/helpers/spacing.dart';
import 'package:popsign/core/theme/styles.dart';
import 'package:popsign/core/widgets/linear_button.dart';
import 'package:popsign/features/initialization/ui/screens/dashboard_screen.dart';
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
      final user = FirebaseAuth.instance.currentUser;

      // ❗ حماية لو المستخدم مش عامل login
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      String uid = user.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        "level": selectedLevel,
        "completedLevels": [],
        "learnedWords": 0,
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
                'Select categories for\nlearning language',
                style: AppTextStyles.font24BoldWhite,
                textAlign: TextAlign.center,
              ),

              verticalSpace(30),

              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => verticalSpace(12),
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
                              ? Colors.green.withOpacity(0.3)
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
                '5,000 words cover 97% of the English language',
                style: AppTextStyles.font13RegularWhiteInter,
              ),

              verticalSpace(20),

              LinearButton(
                text: isLoading ? "Loading..." : "Continue",
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