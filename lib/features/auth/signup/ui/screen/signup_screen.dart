import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:popsign/core/helpers/extension.dart';
import 'package:popsign/core/routing/routes.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/logo_and_name.dart';
import '../../../../../core/widgets/text_form_widget.dart';
import '../../../login/ui/widgets/dont_have_account.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      context.pushNamed(Routes.login);
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == 'email-already-in-use') {
        message = "Email already in use";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 35.w),
          width: double.infinity,
          child: Column(
            children: [
              verticalSpace(110),
              const LogoAndName(),
              verticalSpace(36),

              Text("Sign Up", style: AppTextStyles.font24BoldWhite),
              Text(
                "create an account to continue",
                style: AppTextStyles.font13RegularWhite,
              ),

              verticalSpace(28),

              TextFormWidget(
                controller: usernameController,
                hintText: "username",
                icon: Icons.person_2_outlined,
              ),

              verticalSpace(20),

              TextFormWidget(
                controller: emailController,
                hintText: "email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              verticalSpace(20),

              TextFormWidget(
                controller: passwordController,
                hintText: "password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              verticalSpace(20),

              TextFormWidget(
                controller: confirmPasswordController,
                hintText: "confirm password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              verticalSpace(17),

              LinearButton(
                text: isLoading ? "Loading..." : "Sign Up",
                onPressed: isLoading ? null : signUp,
              ),

              verticalSpace(17),

              DontHaveAccount(
                text: "Already have an account? Go to the",
                actionText: 'Login Page',
                onTap: () {
                  context.pushNamed(Routes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}