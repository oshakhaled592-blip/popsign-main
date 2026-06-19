import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/theme/language_notifier.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/text_form_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading  = false;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService().sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141829) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mark_email_read_rounded,
                  color: const Color(0xFF22C55E), size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              S.get('check_your_email'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              S.get('email_sent_instructions'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.login, (_) => false);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                S.get('go_to_login'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF5F7FB);
    final cardColor = isDark ? const Color(0xFF141829) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final btnBg     = isDark ? const Color(0xFF1E1F35) : Colors.grey.shade200;
    const accent    = Color(0xFF22C55E);

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

                SizedBox(height: 40.h),

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

                SizedBox(height: 24.h),

                Center(
                  child: Text(
                    S.get('reset_password'),
                    style: TextStyle(
                        color: textColor,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 8.h),

                Center(
                  child: Text(
                    S.get('reset_email_hint'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subColor, fontSize: 13.sp),
                  ),
                ),

                SizedBox(height: 40.h),

                Text(
                  S.get('email'),
                  style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _emailCtrl,
                  hintText: S.get('email'),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final val = (v ?? '').trim();
                    if (val.isEmpty) return S.get('email_required');
                    if (!val.contains('@') || !val.contains('.')) {
                      return S.get('email_invalid');
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14.r),
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
                          S.get('reset_step1_hint'),
                          style:
                              TextStyle(color: subColor, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                LinearButton(
                  text: _isLoading
                      ? S.get('loading')
                      : S.get('send_reset_link'),
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
}
