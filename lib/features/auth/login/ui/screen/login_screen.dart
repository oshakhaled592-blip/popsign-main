import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      final email = _emailController.text.trim();
      await prefs.setString('userEmail', email);
      // لو مفيش اسم محفوظ من قبل، نشيله من الإيميل تلقائياً
      final existingName = prefs.getString('userName') ?? '';
      if (existingName.isEmpty) {
        final nameFromEmail = email.split('@').first.replaceAll('.', ' ').replaceAll('_', ' ');
        await prefs.setString('userName', nameFromEmail);
      }
      if (!mounted) return;
      final hasChosenLanguage = prefs.getString('langCode') != null;
      Navigator.pushReplacementNamed(
        context,
        hasChosenLanguage ? Routes.selectCategories : Routes.startPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),

                const Center(child: LogoAndName(compact: true)),

                SizedBox(height: 55.h),

                Text(
                  S.get('welcome'),
                  style: AppTextStyles.title(context).copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  S.get('login_sub'),
                  style: AppTextStyles.small(context).copyWith(fontSize: 14.sp),
                ),

                SizedBox(height: 35.h),

                TextFormWidget(
                  controller: _emailController,
                  hintText: S.get('email'),
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

                SizedBox(height: 18.h),

                TextFormWidget(
                  controller: _passwordController,
                  hintText: S.get('password'),
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter your password";
                    if (v.length < 6) return "At least 6 characters";
                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.forgotPassword);
                    },
                    child: Text(
                      S.get('forgot'),
                      style: AppTextStyles.small(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                LinearButton(text: S.get('login'), onPressed: _login),

                SizedBox(height: 28.h),

                const Center(child: DontHaveAccount()),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
