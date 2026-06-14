import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:popsign/core/helpers/extension.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      context.pushNamed(Routes.startPage);
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == 'user-not-found') {
        message = "No user found for this email";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 35.w),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoAndName(),
            verticalSpace(36),

            Text("Login", style: AppTextStyles.font24BoldWhite),
            Text(
              "please sign in to continue",
              style: AppTextStyles.font13RegularWhite,
            ),

            verticalSpace(28),

            TextFormWidget(
              controller: emailController,
              hintText: "email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            verticalSpace(20),

            TextFormWidget(
              controller: passwordController,
              hintText: "Password",
              icon: Icons.lock_outline,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),

            verticalSpace(17),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Forgot Password?",
                style: AppTextStyles.font13Regularpink,
              ),
            ),

            verticalSpace(17),

            LinearButton(
              text: "Login",
              onPressed: login,
            ),

            verticalSpace(17),

            DontHaveAccount(
              text: "Don't have an account? please ",
              actionText: 'Sign Up',
              onTap: () {
                context.pushNamed(Routes.signup);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}