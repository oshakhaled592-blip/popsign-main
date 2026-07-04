import 'package:flutter/material.dart';
import 'package:popsign/features/initialization/ui/screens/choose_language_screen.dart';
import 'package:popsign/features/initialization/ui/screens/splash_screen.dart';
import 'package:popsign/features/initialization/ui/screens/dashboard_screen.dart';
import 'package:popsign/features/initialization/ui/screens/levels_screen.dart';
import 'package:popsign/features/initialization/ui/screens/onboarding_screen.dart';
import 'package:popsign/features/initialization/ui/screens/select_categories_screen.dart';
import 'package:popsign/features/initialization/ui/screens/about_you_screen.dart';
import 'package:popsign/features/initialization/ui/screens/purpose_screen.dart';
import 'package:popsign/features/initialization/ui/screens/level_intro_screen.dart';
import 'package:popsign/features/initialization/ui/screens/level_options_screen.dart';
import 'package:popsign/features/initialization/ui/screens/study_time_screen.dart';
import 'package:popsign/features/initialization/ui/screens/start_page_screen.dart';
import 'package:popsign/features/initialization/ui/screens/profile._screen.dart';
import 'package:popsign/features/initialization/ui/screens/account_info_screen.dart';
import 'package:popsign/features/initialization/ui/screens/chat_screen.dart';
import 'package:popsign/features/initialization/ui/screens/lost_page_screen.dart';
import 'package:popsign/features/initialization/ui/screens/sign_practice_screen.dart';
import 'package:popsign/features/initialization/ui/screens/reset_screen.dart';
import 'routes.dart';
import '../../features/auth/login/ui/screen/login_screen.dart';
import '../../features/auth/login/ui/screen/change_password_screen.dart';
import '../../features/auth/signup/ui/screen/signup_screen.dart';
import '../../features/auth/signup/ui/screen/check_email_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // boot
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      // auth
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
case Routes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case Routes.checkEmail:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => CheckEmailScreen(email: email));

      // onboarding & start
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.startPage:
        return MaterialPageRoute(builder: (_) => const StartPageScreen());
      case Routes.selectLanguage:
        return MaterialPageRoute(builder: (_) => const ChooseLanguageScreen());
      case Routes.selectCategories:
        return MaterialPageRoute(builder: (_) => const SelectCategoriesScreen());
      case Routes.aboutYou:
        return MaterialPageRoute(builder: (_) => const AboutYouScreen());
      case Routes.purpose:
        return MaterialPageRoute(builder: (_) => const PurposeScreen());
      case Routes.levelIntro:
        return MaterialPageRoute(builder: (_) => const LevelIntroScreen());
      case Routes.levelOptions:
        return MaterialPageRoute(builder: (_) => const LevelOptionsScreen());
      case Routes.studyTime:
        return MaterialPageRoute(builder: (_) => const StudyTimeScreen());

      // main app
      case Routes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Routes.levels:
        return MaterialPageRoute(builder: (_) => const LevelsScreen());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.accountInfo:
        return MaterialPageRoute(builder: (_) => const AccountInfoScreen());
      case Routes.chatScreen:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case Routes.lostPage:
        return MaterialPageRoute(builder: (_) => const LostPage());
      case Routes.signPractice:
        final args = settings.arguments;
        final String word;
        final String videoUrl;
        final String englishWord;
        if (args is Map) {
          word        = (args['word']        ?? '').toString();
          videoUrl    = (args['videoUrl']    ?? '').toString();
          englishWord = (args['englishWord'] ?? '').toString();
        } else {
          word        = args?.toString() ?? '';
          videoUrl    = '';
          englishWord = '';
        }
        return MaterialPageRoute(
          builder: (_) => SignPracticeScreen(
            targetWord:  word,
            videoUrl:    videoUrl,
            englishWord: englishWord,
          ),
        );
      case Routes.reset:
        return MaterialPageRoute(builder: (_) => const ResetScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
