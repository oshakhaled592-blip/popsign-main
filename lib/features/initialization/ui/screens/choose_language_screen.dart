import 'package:flutter/material.dart';
import '../../../../core/theme/styles.dart';
import '../../../../core/widgets/linear_button.dart';

class ChooseLanguageScreen extends StatelessWidget {
  const ChooseLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Language",
            style: AppTextStyles.title(context)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearButton(
              text: "English",
              onPressed: () {
                Navigator.pushNamed(context, "/selectCategories");
              },
            ),

            const SizedBox(height: 15),

            LinearButton(
              text: "Arabic",
              onPressed: () {
                Navigator.pushNamed(context, "/selectCategories");
              },
            ),
          ],
        ),
      ),
    );
  }
}