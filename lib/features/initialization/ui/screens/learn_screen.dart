import 'package:flutter/material.dart';
import 'package:popsign/core/routing/routes.dart';

class LearnScreen extends StatefulWidget {
  final String word;
  final String image;

  const LearnScreen({
    super.key,
    required this.word,
    required this.image,
  });

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool showTranslation = false;

  final Map<String, String> translations = {
    'mother': 'mama',
    'father': 'papa',
    'brother': 'akh',
    'sister': 'okht',
  };

  final Map<String, String> pronunciations = {
    'mother': "ˈmʌðə",
    'father': "ˈfɑːðə",
    'brother': "ˈbrʌðə",
    'sister': "ˈsɪstə",
  };

  String get translation =>
      translations[widget.word.toLowerCase()] ?? widget.word;

  String get pronunciation =>
      pronunciations[widget.word.toLowerCase()] ?? widget.word;

  void toggleTranslation() {
    setState(() {
      showTranslation = !showTranslation;
    });
  }

  void goToIKnow() {
    Navigator.pushNamed(
      context,
      Routes.iKnow,
      arguments: {
        'word': widget.word,
        'image': widget.image,
      },
    );
  }

  void nextWord() {
    Navigator.pop(context, true); // يرجع ويزود progress
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            children: [
              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    "Learn",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 30),

              /// WORD
              Text(
                widget.word,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              /// PRONUNCIATION
              Text(
                "[$pronunciation]",
                style: const TextStyle(color: Colors.white38),
              ),

              const SizedBox(height: 30),

              /// 👁️ CARD
              Expanded(
                child: GestureDetector(
                  onTap: toggleTranslation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        /// 👁️ ICON
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: showTranslation ? 0 : 1,
                          child: const Center(
                            child: Icon(
                              Icons.visibility_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        ),

                        /// 🔥 TRANSLATION
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: showTranslation ? 1 : 0,
                          child: Center(
                            child: Text(
                              translation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTONS
              Row(
                children: [
                  /// I KNOW
                  Expanded(
                    child: GestureDetector(
                      onTap: goToIKnow,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Center(
                          child: Text(
                            "I Know",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// NEXT
                  Expanded(
                    child: GestureDetector(
                      onTap: nextWord,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFFF5A5F),
                        ),
                        child: const Center(
                          child: Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}