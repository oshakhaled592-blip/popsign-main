import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helpers/extension.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/language_notifier.dart';
import '../widgets/quiz_step_scaffold.dart';

class PurposeScreen extends StatefulWidget {
  const PurposeScreen({super.key});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  String? selected;

  final List<Map<String, dynamic>> options = const [
    {'key': 'family', 'titleKey': 'purpose_family', 'icon': Icons.diversity_3_outlined},
    {'key': 'entertainment', 'titleKey': 'purpose_entertainment', 'icon': Icons.movie_outlined},
    {'key': 'work', 'titleKey': 'purpose_work', 'icon': Icons.work_outline_rounded},
    {'key': 'travel', 'titleKey': 'purpose_travel', 'icon': Icons.flight_takeoff_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final language = languageNotifier.value.name;

    return QuizScaffold(
      step: 2,
      totalSteps: 5,
      buttonText: S.get('continue'),
      onContinue: selected == null
          ? null
          : () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('onb_purpose', selected!);
              if (context.mounted) context.pushNamed(Routes.levelIntro);
            },
      child: SingleChildScrollView(
        child: Column(
          children: [
            QuestionHeader(
              emoji: '🎯',
              title: S.get('quiz_why_study').replaceAll('{lang}', language),
            ),
            verticalSpace(28),
            ...options.map((o) => QuizOptionCard(
                  title: S.get(o['titleKey'] as String),
                  icon: o['icon'] as IconData,
                  selected: selected == o['key'],
                  onTap: () => setState(() => selected = o['key'] as String),
                )),
          ],
        ),
      ),
    );
  }
}
