import 'package:flutter/material.dart';
import '../../../../core/widgets/logo_and_name.dart';
import '../../../../core/widgets/linear_button.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),

              const LogoAndName(),

              const Spacer(),

              LinearButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.pushNamed(context, "/chooseLanguage");
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}