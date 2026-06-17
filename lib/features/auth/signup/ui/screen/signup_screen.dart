import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:popsign/core/helpers/extension.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/services/auth_service.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/language_notifier.dart';
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

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.get('passwords_no_match'))),
      );
      return;
    }

    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final result = await AuthService().signup(
      email: email,
      password: passwordController.text.trim(),
    );

    if (!result.success) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final username = usernameController.text.trim();
    if (username.isNotEmpty) {
      await prefs.setString('userName', username);
    }

    // The backend has no endpoint to persist these yet, so they're kept
    // locally instead (matching how learning progress is already stored).
    final priorKnowledge = prefs.getString('onb_priorKnowledge');
    final purpose = prefs.getString('onb_purpose');
    final level = prefs.getString('onb_level');
    final minutesPerDay = prefs.getInt('onb_minutesPerDay');

    if (priorKnowledge != null) await prefs.setString('userPriorKnowledge', priorKnowledge);
    if (purpose != null) await prefs.setString('userPurpose', purpose);
    if (level != null) {
      await prefs.setString('userLevel', level);
      await prefs.setBool('hasSelectedLevel', true);
    }
    if (minutesPerDay != null) await prefs.setInt('userMinutesPerDay', minutesPerDay);

    await prefs.remove('onb_priorKnowledge');
    await prefs.remove('onb_purpose');
    await prefs.remove('onb_level');
    await prefs.remove('onb_minutesPerDay');

    if (!mounted) return;
    setState(() => isLoading = false);

    context.pushNamedAndRemoveUntil(
      Routes.checkEmail,
      arguments: email,
      predicate: (route) => false,
    );
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

              Text(S.get('signup'), style: AppTextStyles.font24BoldWhite),
              Text(
                S.get('signup_subtitle'),
                style: AppTextStyles.font13RegularWhite,
              ),

              verticalSpace(28),

              TextFormWidget(
                controller: usernameController,
                hintText: S.get('username'),
                icon: Icons.person_2_outlined,
              ),

              verticalSpace(20),

              TextFormWidget(
                controller: emailController,
                hintText: S.get('email'),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              verticalSpace(20),

              TextFormWidget(
                controller: passwordController,
                hintText: S.get('password'),
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              verticalSpace(20),

              TextFormWidget(
                controller: confirmPasswordController,
                hintText: S.get('confirm_password'),
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              verticalSpace(17),

              LinearButton(
                text: S.get('signup'),
                onPressed: isLoading ? null : signUp,
              ),

              verticalSpace(17),

              DontHaveAccount(
                text: S.get('already_have'),
                actionText: S.get('login_page'),
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
    languageNotifier.removeListener(_rebuild);
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}