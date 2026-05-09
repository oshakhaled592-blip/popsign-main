import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/language_notifier.dart';
import '../../../../../core/theme/styles.dart';

class DontHaveAccount extends StatefulWidget {
  const DontHaveAccount({super.key});

  @override
  State<DontHaveAccount> createState() => _DontHaveAccountState();
}

class _DontHaveAccountState extends State<DontHaveAccount> {
  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(S.get('dont_have'), style: AppTextStyles.small(context)),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.signup),
          child: Text(
            S.get('signup'),
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
