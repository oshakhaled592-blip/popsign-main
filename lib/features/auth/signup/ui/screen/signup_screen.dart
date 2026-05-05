import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                const LogoAndName(),

                const SizedBox(height: 40),

                TextFormWidget(
                  controller: nameController,
                  hintText: "Full Name",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 15),

                TextFormWidget(
                  controller: emailController,
                  hintText: "Email",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 15),

                TextFormWidget(
                  controller: passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                LinearButton(
                  text: "Sign Up",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // signup logic
                    }
                  },
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: AppTextStyles.small(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}