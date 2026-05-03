import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/app_colors.dart';
import 'package:popsign/core/theme/styles.dart';
import 'package:popsign/core/widgets/text_form_widget.dart';
import 'package:popsign/features/auth/login/ui/widgets/dont_have_account.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // ── Back button ──────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42.w,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: AppColors.darkGray,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Logo + App name ──────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/Logo.png',
                        height: 56.h,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.hearing_rounded,
                          size: 56.h,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "I Hear You",
                        style: AppTextStyles.font16boldWhite,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Title ────────────────────────────────────────────
                Text(
                  "Create Account",
                  style: AppTextStyles.font24BoldWhite,
                ),
                SizedBox(height: 5.h),
                Text(
                  "Sign up to start learning words",
                  style: AppTextStyles.font13RegularGray,
                ),

                SizedBox(height: 24.h),

                // ── Username ─────────────────────────────────────────
                _label("Username"),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _usernameController,
                  hintText: "Enter your username",
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Please enter your username";
                    }
                    if (v.trim().length < 3) {
                      return "At least 3 characters";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // ── Email ────────────────────────────────────────────
                _label("Email"),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _emailController,
                  hintText: "Enter your email",
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

                SizedBox(height: 16.h),

                // ── Password ─────────────────────────────────────────
                _label("Password"),
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

                SizedBox(height: 16.h),

                // ── Confirm Password ─────────────────────────────────
                _label("Confirm Password"),
                SizedBox(height: 8.h),
                TextFormWidget(
                  controller: _confirmPasswordController,
                  hintText: "Re-enter your password",
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (v != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30.h),

                // ── Sign Up Button ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.linear1, AppColors.linear2],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.linear1.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _signup,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: AppTextStyles.font16boldWhite,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                // ── Login link ───────────────────────────────────────
                Center(
                  child: DontHaveAccount(
                    text: "Already have an account?",
                    actionText: "Login",
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      );
}
