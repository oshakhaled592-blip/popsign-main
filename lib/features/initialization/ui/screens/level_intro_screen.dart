import 'package:flutter/material.dart';

import '../../../../core/helpers/extension.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/quiz_step_scaffold.dart';

class LevelIntroScreen extends StatelessWidget {
  const LevelIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 3,
      totalSteps: 5,
      buttonText: S.get('choose_level_btn'),
      onContinue: () => context.pushNamed(Routes.levelOptions),
      child: SingleChildScrollView(
        child: Center(
          child: QuestionHeader(
            emoji: '🧭',
            title: S.get('know_level_title'),
            subtitle: S.get('know_level_subtitle'),
          ),
        ),
      ),
    );
  }
}
