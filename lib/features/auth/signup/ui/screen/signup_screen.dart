import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/extension.dart';
import 'package:popsign/core/routing/routes.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/logo_and_name.dart';
import '../../../../../core/widgets/text_form_widget.dart';
import '../../../login/ui/widgets/dont_have_account.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Form(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            width: double.infinity.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpace(110),
                LogoAndName(),
                verticalSpace(36),
                Text("Sign Up", style: AppTextStyles.font24BoldWhite),
                Text(
                  "create an account to continue",
                  style: AppTextStyles.font13RegularWhite,
                ),
                verticalSpace(28),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormWidget(
                      autofocus: true,
                      controller: usernameController,
                      hintText: "username",
                      icon: Icons.person_2_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    verticalSpace(20),
                    TextFormWidget(
                      autofocus: true,
                      controller: emailController,
                      hintText: "email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    verticalSpace(20),
                    TextFormWidget(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      hintText: "Password",
                      obscureText: true,
                      icon: Icons.lock_outline,
                    ),
                    verticalSpace(20),
                    TextFormWidget(
                      controller: confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      hintText: "confirm password",
                      obscureText: true,
                      icon: Icons.lock_outline,
                    ),
                    verticalSpace(7),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot Password?",
                        style: AppTextStyles.font13Regularpink,
                      ),
                    ),
                    verticalSpace(17),
                    LinearButton(text: "Sign Up", onPressed: () {
                      context.pushNamed(Routes.login);
                    }),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
