import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helpers/extension.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/quiz_step_scaffold.dart';

class AboutYouScreen extends StatefulWidget {
  const AboutYouScreen({super.key});

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 1,
      totalSteps: 5,
      buttonText: S.get('continue'),
      onContinue: selected == null
          ? null
          : () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('onb_priorKnowledge', selected!);
              if (context.mounted) context.pushNamed(Routes.purpose);
            },
      child: SingleChildScrollView(
        child: Column(
          children: [
            QuestionHeader(
              emoji: '👋',
              title: S.get('quiz_welcome_title'),
            ),
            verticalSpace(28),
            QuizOptionCard(
              title: S.get('quiz_dont_know').replaceAll('{lang}', 'ASL'),
              icon: Icons.sentiment_neutral_rounded,
              selected: selected == 'none',
              onTap: () => setState(() => selected = 'none'),
            ),
            QuizOptionCard(
              title: S.get('quiz_already_studied').replaceAll('{lang}', 'ASL'),
              icon: Icons.school_outlined,
              selected: selected == 'studied',
              onTap: () => setState(() => selected = 'studied'),
            ),
          ],
        ),
      ),
    );
  }
}
