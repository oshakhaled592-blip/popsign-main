import 'package:flutter/material.dart';
import 'package:popsign/features/initialization/ui/screens/choose_language_screen.dart';
import 'package:popsign/features/initialization/ui/screens/select_categories_screen.dart';
import 'package:popsign/features/initialization/ui/screens/start_page_screen.dart';
import 'routes.dart';
import '../../features/auth/login/ui/screen/login_screen.dart';
import '../../features/auth/signup/ui/screen/signup_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // auth
      case Routes.login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (context) => const SignupScreen());

      // start and initialization 
      case Routes.startPage:
        return MaterialPageRoute(builder: (context) => const StartPageScreen());
      case Routes.selectLanguage:
        return MaterialPageRoute(builder: (context) => const ChooseLanguageScreen());
      case Routes.selectCategories:
        return MaterialPageRoute(builder: (context) => const SelectCategoriesScreen());
      default:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
    }
  }
}
