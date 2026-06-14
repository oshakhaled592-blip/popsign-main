import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/language_notifier.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/text_form_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _done = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final btnBg = isDark ? const Color(0xFF171C2B) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),

                Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: btnBg,
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

                SizedBox(height: 32.h),

                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: const Color(0xFF22C55E),
                      size: 40.sp,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Center(
                  child: Text(
                    "Reset Password",
                    style: AppTextStyles.font24BoldWhite.copyWith(
                      fontSize: 26.sp,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Center(
                  child: Text(
                    "Enter your new password below",
                    style: AppTextStyles.font13RegularGray.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                if (!_done) ...[
                  TextFormWidget(
                    controller: _newPasswordController,
                    hintText: S.get('new_password'),
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  SizedBox(height: 18.h),

                  TextFormWidget(
                    controller: _confirmController,
                    hintText: S.get('confirm_password'),
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  SizedBox(height: 36.h),

                  LinearButton(
                    text: S.get('reset_password'),
                    onPressed: _submit,
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.h,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 36.sp,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        Text(
                          "Password reset!",
                          style: AppTextStyles.font24BoldWhite.copyWith(
                            fontSize: 22.sp,
                            color: const Color(0xFF22C55E),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          "Taking you back to login...",
                          style: AppTextStyles.font13RegularGray.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
