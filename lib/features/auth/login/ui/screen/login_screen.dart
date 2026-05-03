import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/logo_and_name.dart';
import '../../../../../core/widgets/text_form_widget.dart';
import '../widgets/dont_have_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, Routes.startPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  verticalSpace(60),

                  /// 🔥 Logo
                  const LogoAndName(),

                  verticalSpace(36),

                  /// 🔥 Title
                  Text("Login", style: AppTextStyles.font24BoldWhite),

                  Text(
                    "please sign in to continue",
                    style: AppTextStyles.font13RegularWhite,
                  ),

                  verticalSpace(28),

                  /// 🔥 Email
                  TextFormWidget(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!value.contains('@')) {
                        return "Invalid email";
                      }
                      return null;
                    },
                  ),

                  verticalSpace(20),

                  /// 🔥 Password
                  TextFormWidget(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    icon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  verticalSpace(10),

                  /// 🔥 Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.font13Regularpink,
                    ),
                  ),

                  verticalSpace(20),

                  /// 🔥 Login Button
                  LinearButton(
                    text: "Login",
                    onPressed: login,
                  ),

                  verticalSpace(20),

                  /// 🔥 Sign Up
                  DontHaveAccount(
                    text: "Don't have an account? ",
                    actionText: 'Sign Up',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.signup);
                    },
                  ),

                  verticalSpace(30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}