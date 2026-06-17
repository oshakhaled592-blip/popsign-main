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
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // The new backend doesn't expose a password-reset endpoint yet.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Password reset isn't available yet. Please contact support.",
        ),
      ),
    );
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      color: const Color(0xFF22C55E).withValues(alpha: 0.12),
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
                    S.get('reset_password'),
                    style: AppTextStyles.font24BoldWhite.copyWith(
                      fontSize: 26.sp,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Center(
                  child: Text(
                    "Enter your email and we'll send you a reset link",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font13RegularGray.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                TextFormWidget(
                  controller: _emailController,
                  hintText: S.get('email'),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return "Please enter your email";
                    if (!v.contains('@') || !v.contains('.')) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 36.h),

                LinearButton(
                  text: S.get('reset_password'),
                  onPressed: _submit,
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
