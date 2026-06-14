import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/extension.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/styles.dart';
import '../../../../../core/widgets/linear_button.dart';
import '../../../../../core/widgets/logo_and_name.dart';
import '../../../../../core/widgets/text_form_widget.dart';
import '../widgets/dont_have_account.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Form(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 35.w),
          width: double.infinity.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LogoAndName(),
              verticalSpace(36),
              Text("Login", style: AppTextStyles.font24BoldWhite),
              Text(
                "please sign in to continue",
                style: AppTextStyles.font13RegularWhite,
              ),
              verticalSpace(28),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  verticalSpace(7),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.font13Regularpink,
                    ),
                  ),
                  verticalSpace(17),
                  LinearButton(
                    text: "Login",
                    onPressed: () {
                      context.pushNamed(Routes.startPage);
                    },
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
            ],
          ),
        ),
      ),
    );
  }
}
