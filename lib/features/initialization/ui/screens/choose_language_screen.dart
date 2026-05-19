import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helpers/extension.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/theme/styles.dart';
import '../../../../core/widgets/linear_button.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() =>
      _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState
    extends State<ChooseLanguageScreen>
    with SingleTickerProviderStateMixin {
  int? selectedLanguageIndex;

  final _scrollController = ScrollController();
  bool _showArrow = true;

  late AnimationController _arrowController;
  late Animation<double> _arrowAnim;

  final List<Map<String, String>> languages = [
    {"name": "English",    "flag": "🇺🇸"},
    {"name": "Spanish",    "flag": "🇪🇸"},
    {"name": "French",     "flag": "🇫🇷"},
    {"name": "Russian",    "flag": "🇷🇺"},
    {"name": "Arabic",     "flag": "🇸🇦"},
    {"name": "German",     "flag": "🇩🇪"},
    {"name": "Italian",    "flag": "🇮🇹"},
    {"name": "Turkish",    "flag": "🇹🇷"},
    {"name": "Japanese",   "flag": "🇯🇵"},
    {"name": "Chinese",    "flag": "🇨🇳"},
    {"name": "Korean",     "flag": "🇰🇷"},
    {"name": "Portuguese", "flag": "🇵🇹"},
    {"name": "Hindi",      "flag": "🇮🇳"},
    {"name": "Dutch",      "flag": "🇳🇱"},
  ];

  @override
  void initState() {
    super.initState();

    languageNotifier.addListener(_rebuild);

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _arrowAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      final atBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 40;
      if (atBottom != !_showArrow) {
        setState(() => _showArrow = !atBottom);
      }
    });
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _scrollController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 220,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF0F1422) : Colors.white;
    final btnBgColor =
        isDark ? const Color(0xFF171C2B) : Colors.grey.shade200;
    final arrowBg =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100;
    final arrowIcon =
        isDark ? Colors.white60 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: btnBgColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: textColor,
                  ),
                ),
              ),

              verticalSpace(12),

              Center(
                child: SizedBox(
                  width: 300.w,
                  child: Text(
                    S.get('select_lang'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title(context).copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: textColor,
                    ),
                  ),
                ),
              ),

              verticalSpace(20),

              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        final item = languages[index];
                        final isSelected = selectedLanguageIndex == index;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedLanguageIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : isDark
                                        ? const Color(0xFF263047)
                                        : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.15)
                                      : Colors.grey.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(item['flag']!,
                                    style: TextStyle(fontSize: 20.sp)),
                                horizontalSpace(12),
                                Expanded(
                                  child: Text(
                                    item['name']!,
                                    style: AppTextStyles.title(context)
                                        .copyWith(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  width: 26.w,
                                  height: 26.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 16)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    AnimatedOpacity(
                      opacity: _showArrow ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: _scrollDown,
                          child: AnimatedBuilder(
                            animation: _arrowAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(0, _arrowAnim.value),
                              child: child,
                            ),
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              margin: EdgeInsets.only(bottom: 8.h),
                              decoration: BoxDecoration(
                                color: arrowBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: arrowIcon,
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              verticalSpace(20),

              LinearButton(
                text: S.get('continue'),
                width: double.infinity,
                height: 58.h,
                radius: 18.r,
                onPressed: () async {
                  if (selectedLanguageIndex == null) {
                    showCustomSnackBar(context, "Please select a language");
                  } else {
                    final selected = languages[selectedLanguageIndex!];
                    final info = LanguageInfo(
                      name: selected['name']!,
                      flag: selected['flag']!,
                      code: selected['name']!.toLowerCase().substring(0, 2),
                    );
                    languageNotifier.value = info;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('langCode', info.code);
                    await prefs.setString('langName', info.name);
                    await prefs.setString('langFlag', info.flag);
                    if (context.mounted) {
                      final args = ModalRoute.of(context)?.settings.arguments
                          as Map?;
                      final fromSettings = args?['fromSettings'] == true;
                      if (fromSettings) {
                        Navigator.pop(context);
                      } else {
                        context.pushNamedAndRemoveUntil(
                          Routes.selectCategories,
                          predicate: (route) => false,
                        );
                      }
                    }
                  }
                },
              ),

              verticalSpace(10),
            ],
          ),
        ),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r)),
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 30.h),
    ),
  );
}
