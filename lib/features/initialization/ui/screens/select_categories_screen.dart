import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/widgets/linear_button.dart';
import 'pre_start_screen.dart';

class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<SelectCategoriesScreen> createState() =>
      _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  final _scrollController = ScrollController();
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _scrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> categories = [
    {'level': 'A1', 'words': '1-100 words',   'percent': '80%', 'color': const Color(0xFF00B894)},
    {'level': 'A2', 'words': '101 - 1k words', 'percent': '44%', 'color': const Color(0xFF74B816)},
    {'level': 'B1', 'words': '1k - 2k words',  'percent': '27%', 'color': const Color(0xFFD4AC0D)},
    {'level': 'B2', 'words': '2k - 3k words',  'percent': '9%',  'color': const Color(0xFFD96C06)},
    {'level': 'C1', 'words': '3k - 4k words',  'percent': '',    'color': const Color(0xFFFF5722)},
    {'level': 'C2', 'words': '4k - 5k words',  'percent': '',    'color': const Color(0xFFE91E63)},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090E1A) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
          child: Column(
            children: [
              verticalSpace(16),

              /// TITLE
              Center(
                child: SizedBox(
                  width: 290.w,
                  child: Text(
                    S.get('select_level'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1C1C1C),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ),

              verticalSpace(20),

              /// CATEGORY LIST
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF151922),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46.w,
                                height: 32.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  borderRadius: BorderRadius.circular(11.r),
                                ),
                                child: Text(
                                  item['level'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              horizontalSpace(14),

                              Expanded(
                                child: Text(
                                  item['words'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              if (item['percent'] != '')
                                Padding(
                                  padding: EdgeInsets.only(right: 14.w),
                                  child: Text(
                                    item['percent'],
                                    style: TextStyle(
                                      color: const Color(0xFF7B8190),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 28.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF4A5672),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 18)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              verticalSpace(8),

              Text(
                "5,000 words cover 97% of the English language",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF8B90A0),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),

              verticalSpace(38),

              LinearButton(
                text: S.get('continue'),
                width: double.infinity,
                height: 58.h,
                radius: 18.r,
                onPressed: () {
                  if (selectedIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please select a level"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreStartScreen(
                        selectedCategory: categories[selectedIndex!],
                      ),
                    ),
                  );
                },
              ),

              verticalSpace(18),
            ],
          ),
        ),
      ),
    );
  }
}
