import 'package:flutter/material.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/features/initialization/ui/screens/splash_screen.dart';
import 'package:popsign/features/auth/login/ui/screen/login_screen.dart';
import 'package:popsign/features/auth/signup/ui/screen/signup_screen.dart';
import 'package:popsign/features/auth/login/ui/screen/forgot_password_screen.dart';
import 'package:popsign/features/initialization/ui/screens/get_started_screen.dart';
import 'package:popsign/features/initialization/ui/screens/choose_language_screen.dart';
import 'package:popsign/features/initialization/ui/screens/select_categories_screen.dart';
import 'package:popsign/features/initialization/ui/screens/pre_start_screen.dart';
import 'package:popsign/features/initialization/ui/screens/word_list_screen.dart';
import 'package:popsign/features/initialization/ui/screens/learn_new_words_screen.dart';
import 'package:popsign/features/initialization/ui/screens/reset_screen.dart';
import '../../features/initialization/ui/screens/lost_page_screen.dart';
import '../../features/initialization/ui/screens/profile._screen.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      /// 🟡 SPLASH
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      /// 🔐 LOGIN
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      /// 📝 SIGNUP
      case Routes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      /// 🔑 FORGOT PASSWORD
      case Routes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      /// 🚀 GET STARTED
      case Routes.startPage:
        return MaterialPageRoute(
          builder: (_) => const GetStartedScreen(),
        );

      /// 🌍 CHOOSE LANGUAGE
      case Routes.selectLanguage:
        return MaterialPageRoute(
          builder: (_) => const ChooseLanguageScreen(),
        );

      /// 🧠 SELECT CATEGORIES
      case Routes.selectCategories:
        return MaterialPageRoute(
          builder: (_) => const SelectCategoriesScreen(),
        );

      /// ⏳ PRE START
      case Routes.preStart:
        return MaterialPageRoute(
          builder: (_) => const PreStartScreen(),
        );

      /// 📚 WORD LIST
      case Routes.wordList:
        return MaterialPageRoute(
          builder: (_) => const WordListScreen(),
        );

      /// 🔥 LEARN NEW WORDS
      case Routes.learnNewWords:
        return MaterialPageRoute(
          builder: (_) => const LearnNewWordsScreen(),
        );

      /// 👤 PROFILE
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      /// 💔 LOST PAGE
      case Routes.lostPage:
        return MaterialPageRoute(
          builder: (_) => const LostPage(),
        );

      /// 🔴 RESET
      case Routes.reset:
        return MaterialPageRoute(
          builder: (_) => const ResetScreen(),
        );

      /// ❌ DEFAULT
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Color(0xff090B14),
            body: Center(
              child: Text(
                "No Route Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
    }
  }
}