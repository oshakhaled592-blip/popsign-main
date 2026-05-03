import 'package:flutter/material.dart';
import 'package:popsign/features/initialization/ui/screens/splash_screen.dart';
import 'package:popsign/features/auth/login/ui/screen/login_screen.dart';
import 'package:popsign/features/auth/signup/ui/screen/signup_screen.dart';
import 'package:popsign/features/initialization/ui/screens/get_started_screen.dart';
import 'package:popsign/features/initialization/ui/screens/choose_language_screen.dart';
import 'package:popsign/features/initialization/ui/screens/select_categories_screen.dart';
import 'package:popsign/features/initialization/ui/screens/pre_start_screen.dart';
import 'package:popsign/features/initialization/ui/screens/word_list_screen.dart';
import 'package:popsign/features/initialization/ui/screens/learn_new_words_screen.dart';
import 'package:popsign/features/initialization/ui/screens/profile._screen.dart';
import 'package:popsign/features/initialization/ui/screens/reset_screen.dart';
import 'routes.dart';

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

      /// 🚀 START
      case Routes.startPage:
        return MaterialPageRoute(
          builder: (_) => const GetStartedScreen(),
        );

      /// 🌍 LANGUAGE
      case Routes.selectLanguage:
        return MaterialPageRoute(
          builder: (_) => const ChooseLanguageScreen(),
        );

      /// 🧠 CATEGORIES
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

      /// 🔥 LEARN NEW WORDS (UPDATED)
      case Routes.learnNewWords:
        return MaterialPageRoute(
          builder: (_) => const LearnNewWordsScreen(),
        );

      /// 👤 PROFILE
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
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
            body: Center(
              child: Text("No Route Found"),
            ),
          ),
        );
    }
  }
}