import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/language_notifier.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/logo_and_name.dart';
import '../../../../../core/widgets/text_form_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setString('userEmail', _emailController.text.trim());
      if (mounted) Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                const Center(child: LogoAndName(compact: true)),

                SizedBox(height: 36.h),

                Text(
                  S.get('create_account'),
                  style: AppTextStyles.title(context).copyWith(fontSize: 26.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  S.get('signup_sub'),
                  style: AppTextStyles.small(context).copyWith(fontSize: 14.sp),
                ),

                SizedBox(height: 28.h),

                _label(S.get('full_name'), context),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _nameController,
                  hintText: S.get('full_name'),
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Please enter your name";
                    if (v.trim().length < 3) return "At least 3 characters";
                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                _label(S.get('email'), context),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _emailController,
                  hintText: S.get('email'),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter your email";
                    if (!v.contains('@') || !v.contains('.')) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                _label(S.get('password'), context),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _passwordController,
                  hintText: S.get('password'),
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter a password";
                    if (v.length < 6) return "At least 6 characters";
                    return null;
                  },
                ),

                SizedBox(height: 38.h),

                LinearButton(text: S.get('signup'), onPressed: _submit),

                SizedBox(height: 24.h),

                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.small(context)
                            .copyWith(fontSize: 14.sp),
                        children: [
                          TextSpan(text: "${S.get('already_have')}  "),
                          TextSpan(
                            text: S.get('login'),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _label(String text, BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 2.w),
        child: Text(
          text,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
