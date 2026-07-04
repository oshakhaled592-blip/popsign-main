import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/theme/language_notifier.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/text_form_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService().changePassword(
      currentPassword: _currentController.text.trim(),
      newPassword: _newController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor  = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor  = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor   = isDark ? Colors.white54 : AppColors.grayTextLight;
    final btnBg      = isDark ? const Color(0xFF1E1F35) : Colors.grey.shade100;
    const accent     = AppColors.accent;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: btnBg,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: textColor, size: 18.sp),
                  ),
                ),

                SizedBox(height: 32.h),

                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_reset_rounded,
                        color: accent, size: 40.sp),
                  ),
                ),

                SizedBox(height: 20.h),

                Center(
                  child: Text(
                    S.get('change_password'),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                Center(
                  child: Text(
                    S.get('change_password_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subColor, fontSize: 13.sp),
                  ),
                ),

                SizedBox(height: 36.h),

                _label(S.get('current_password'), textColor),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _currentController,
                  hintText: S.get('current_password'),
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) {
                      return S.get('current_password_required');
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                _label(S.get('new_password'), textColor),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _newController,
                  hintText: S.get('new_password'),
                  icon: Icons.lock_open_rounded,
                  obscureText: true,
                  validator: (v) {
                    final val = (v ?? '').trim();
                    if (val.isEmpty) return S.get('new_password_required');
                    if (val.length < 6) return S.get('password_too_short');
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                _label(S.get('confirm_new_password'), textColor),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _confirmController,
                  hintText: S.get('confirm_new_password'),
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if ((v ?? '').trim() != _newController.text.trim()) {
                      return S.get('passwords_no_match');
                    }
                    return null;
                  },
                ),

                SizedBox(height: 36.h),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.2 : 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: accent, size: 18.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          S.get('password_hint'),
                          style:
                              TextStyle(color: subColor, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                LinearButton(
                  text: _isLoading ? S.get('loading') : S.get('change_password'),
                  onPressed: _isLoading ? null : _submit,
                  width: double.infinity.w,
                  radius: 14.r,
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      );
}
