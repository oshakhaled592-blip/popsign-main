import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

                /// 🔥 LOGO
                const LogoAndName(),

                const SizedBox(height: 40),

                /// EMAIL
                TextFormWidget(
                  controller: emailController,
                  hintText: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                /// PASSWORD
                TextFormWidget(
                  controller: passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                /// LOGIN BUTTON
                LinearButton(
                  text: "Login",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // TODO: login logic
                    }
                  },
                ),

                const SizedBox(height: 20),

                /// DON'T HAVE ACCOUNT
                const DontHaveAccount(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}