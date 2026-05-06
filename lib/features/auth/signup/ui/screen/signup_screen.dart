import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/routing/routes.dart';
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ── Back button ───────────────────────────────────
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
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Logo ──────────────────────────────────────────
                const Center(child: LogoAndName()),

                SizedBox(height: 36.h),

                // ── Title ─────────────────────────────────────────
                Text(
                  "Create Account",
                  style: AppTextStyles.title(context)
                      .copyWith(fontSize: 26.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Sign up to start learning words",
                  style: AppTextStyles.small(context),
                ),

                SizedBox(height: 28.h),

                // ── Full Name ─────────────────────────────────────
                _label("Full Name", context),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _nameController,
                  hintText: "Enter your full name",
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Please enter your name";
                    }
                    if (v.trim().length < 3) return "At least 3 characters";
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // ── Email ─────────────────────────────────────────
                _label("Email", context),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _emailController,
                  hintText: "Enter your email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // ── Password ──────────────────────────────────────
                _label("Password", context),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _passwordController,
                  hintText: "Create a password",
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter a password";
                    if (v.length < 6) return "At least 6 characters";
                    return null;
                  },
                ),

                SizedBox(height: 36.h),

                // ── Sign Up button ────────────────────────────────
                LinearButton(
                  text: "Sign Up",
                  onPressed: _submit,
                ),

                SizedBox(height: 20.h),

                // ── Login link ────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
                    child: Text(
                      "Already have an account?  Login",
                      style: AppTextStyles.small(context),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Text(
          text,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
