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
import 'package:popsign/features/initialization/ui/screens/reset_screen.dart';
import '../../features/initialization/ui/screens/lost_page_screen.dart';
import '../../features/initialization/ui/screens/profile._screen.dart';
import '../../features/initialization/ui/screens/account_info_screen.dart';
import '../../features/initialization/ui/screens/onboarding_screen.dart';
import '../../features/initialization/ui/screens/sign_practice_screen.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case Routes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case Routes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case Routes.startPage:
        return MaterialPageRoute(
          builder: (_) => const GetStartedScreen(),
        );

      case Routes.selectLanguage:
        return MaterialPageRoute(
          builder: (_) => const ChooseLanguageScreen(),
        );

      case Routes.selectCategories:
        return MaterialPageRoute(
          builder: (_) => const SelectCategoriesScreen(),
        );

      case Routes.preStart:
        return MaterialPageRoute(
          builder: (_) => const PreStartScreen(),
        );

      case Routes.wordList:
        return MaterialPageRoute(
          builder: (_) => const WordListScreen(),
        );


      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case Routes.lostPage:
        return MaterialPageRoute(
          builder: (_) => const LostPage(),
        );

      case Routes.accountInfo:
        return MaterialPageRoute(
          builder: (_) => const AccountInfoScreen(),
        );

      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case Routes.signPractice:
        final word = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SignPracticeScreen(targetWord: word),
        );

      case Routes.reset:
        return MaterialPageRoute(
          builder: (_) => const ResetScreen(),
        );

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
