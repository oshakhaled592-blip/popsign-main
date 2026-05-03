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
import 'package:popsign/features/initialization/ui/screens/learn_screen.dart';
import 'package:popsign/features/initialization/ui/screens/i_know_screen.dart';
import 'package:popsign/features/initialization/ui/screens/profile._screen.dart';
import 'package:popsign/features/initialization/ui/screens/reset_screen.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case Routes.startPage:
        return MaterialPageRoute(builder: (_) => const GetStartedScreen());

      case Routes.selectLanguage:
        return MaterialPageRoute(builder: (_) => const ChooseLanguageScreen());

      case Routes.selectCategories:
        return MaterialPageRoute(builder: (_) => const SelectCategoriesScreen());

      case Routes.preStart:
        return MaterialPageRoute(builder: (_) => const PreStartScreen());

      /// WORD LIST
      case Routes.wordList:
        return MaterialPageRoute(builder: (_) => const WordListScreen());

      /// LEARN NEW WORDS
      case Routes.learnNewWords:
        return _buildRoute(
          settings,
          (args) => LearnNewWordsScreen(
            word: args['word'],
            image: args['image'],
          ),
          fallback: const LearnNewWordsScreen(
            word: 'mother',
            image: 'assets/images/mother.png',
          ),
        );

      /// LEARN
      case Routes.learn:
        return _buildRoute(
          settings,
          (args) => LearnScreen(
            word: args['word'],
            image: args['image'],
          ),
          fallback: const LearnScreen(
            word: 'mother',
            image: 'assets/images/mother.png',
          ),
        );

      /// I KNOW
      case Routes.iKnow:
        return _buildRoute(
          settings,
          (args) => IKnowScreen(
            word: args['word'],
            image: args['image'],
          ),
          fallback: const IKnowScreen(
            word: 'mother',
            image: 'assets/images/mother.png',
          ),
        );

      /// PROFILE
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      /// 🔥 RESET SCREEN
      case Routes.reset:
        return MaterialPageRoute(
          builder: (_) => const ResetScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("No Route Found")),
          ),
        );
    }
  }

  Route<dynamic> _buildRoute(
    RouteSettings settings,
    Widget Function(Map<String, dynamic> args) builder, {
    required Widget fallback,
  }) {
    final args = settings.arguments;

    if (args is Map<String, dynamic>) {
      return MaterialPageRoute(builder: (_) => builder(args));
    }

    return MaterialPageRoute(builder: (_) => fallback);
  }
}