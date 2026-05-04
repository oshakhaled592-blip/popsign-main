import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/app_colors.dart';
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
                SizedBox(height: 16.h),

                // ── Back button ──────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.darkGray,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Logo ─────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.linear1, AppColors.linear2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.linear1.withValues(alpha: 0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/Logo.png',
                            width: 42.w,
                            height: 42.h,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.hearing_rounded,
                              size: 36.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "I Hear You",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Title ─────────────────────────────────────────
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "Sign up to start learning words",
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Username ──────────────────────────────────────
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
                    if (v.trim().length < 3) return "At least 3 characters";
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // ── Email ─────────────────────────────────────────
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

                // ── Password ──────────────────────────────────────
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

                // ── Confirm Password ──────────────────────────────
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

                SizedBox(height: 34.h),

                // ── Sign Up Button ────────────────────────────────
                GestureDetector(
                  onTap: _signup,
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.linear1, AppColors.linear2],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.linear1.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                // ── Login link ────────────────────────────────────
                Center(
                  child: DontHaveAccount(
                    text: "Already have an account?",
                    actionText: "Login",
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
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
