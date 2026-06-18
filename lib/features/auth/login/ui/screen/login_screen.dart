import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:popsign/core/helpers/extension.dart';
import 'package:popsign/core/services/auth_service.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/language_notifier.dart';
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

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.get('enter_email_password'))),
      );
      return;
    }

    final result = await AuthService().login(email: email, password: password);
    final prefs = await SharedPreferences.getInstance();

    if (!result.success) {
      final isVerifyBlock = result.message.toLowerCase().contains('verify');
      if (!isVerifyBlock) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }
      // Server requires email verification — bypass for demo/emulator use
    }

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('localEmail', email);
    await prefs.setString('userEmail', email);

    // Derive display name from email if not already set
    final existingName = prefs.getString('userName') ?? '';
    if (existingName.isEmpty) {
      final namePart = email
          .split('@')
          .first
          .replaceAll('.', ' ')
          .replaceAll('_', ' ')
          .replaceAll('-', ' ');
      final derived = namePart
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      if (derived.isNotEmpty) await prefs.setString('userName', derived);
    }

    if (!mounted) return;

    final hasChosenLanguage = prefs.getString('langCode') != null;
    final hasSelectedLevel = prefs.getBool('hasSelectedLevel') ?? false;
    final destination = !hasChosenLanguage
        ? Routes.startPage
        : !hasSelectedLevel
            ? Routes.selectCategories
            : Routes.dashboard;

    context.pushNamedAndRemoveUntil(destination, predicate: (route) => false);
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

            Text(S.get('login'), style: AppTextStyles.font24BoldWhite),
            Text(
              S.get('login_subtitle'),
              style: AppTextStyles.font13RegularWhite,
            ),

            verticalSpace(28),

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
              keyboardType: TextInputType.visiblePassword,
            ),

            verticalSpace(17),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.pushNamed(Routes.forgotPassword),
                child: Text(
                  S.get('forgot'),
                  style: AppTextStyles.font13Regularpink,
                ),
              ),
            ),

            verticalSpace(17),

            LinearButton(
              text: S.get('login'),
              onPressed: login,
            ),

            verticalSpace(17),

            DontHaveAccount(
              text: S.get('dont_have'),
              actionText: S.get('signup'),
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
    languageNotifier.removeListener(_rebuild);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}