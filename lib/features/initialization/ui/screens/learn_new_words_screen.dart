import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordItem {
  final String word;
  final String pronunciation;
  final String translation;

  const WordItem(this.word, this.pronunciation, this.translation);
}

class LearnNewWordsScreen extends StatefulWidget {
  const LearnNewWordsScreen({super.key});

  @override
  State<LearnNewWordsScreen> createState() => _LearnNewWordsScreenState();
}

class _LearnNewWordsScreenState extends State<LearnNewWordsScreen> {
  bool showTranslation = false;
  String mode = "none"; // "none" | "know" | "learn"

  int currentIndex = 0;
  late List<WordItem> words;

  static const _base = [
    WordItem("mother",  "ˈmʌðə",  "mama"),
    WordItem("father",  "ˈfɑːðə",  "papa"),
    WordItem("brother", "ˈbrʌðə", "akh"),
    WordItem("sister",  "ˈsɪstə",  "okht"),
  ];

  @override
  void initState() {
    super.initState();
    words = List.of(_base)..shuffle();
  }

  void _toggleTranslation() {
    HapticFeedback.selectionClick();
    setState(() => showTranslation = !showTranslation);
  }

  void _nextWord() {
    if (!mounted) return;
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        showTranslation = false;
        mode = "none";
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _selectKnow() {
    if (mode != "none") return;
    HapticFeedback.lightImpact();
    setState(() => mode = "know");
    Future.delayed(const Duration(milliseconds: 600), _nextWord);
  }

  void _selectLearn() {
    if (mode != "none") return;
    HapticFeedback.heavyImpact();
    setState(() => mode = "learn");
    Future.delayed(const Duration(milliseconds: 600), _nextWord);
  }

  @override
  Widget build(BuildContext context) {
    final word = words[currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1C);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // ── HEADER ──────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textColor,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Learn new words",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),

              const SizedBox(height: 20),

              // ── CARD ─────────────────────────────────────────
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0.0,
                    end: mode == "learn"
                        ? 0.12
                        : mode == "know"
                            ? -0.12
                            : 0.0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, angle, child) =>
                      Transform.rotate(angle: angle, child: child),
                  child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF18202E), Color(0xFF10141F)],
                    ),
                    boxShadow: mode == "know"
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ]
                        : mode == "learn"
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.35),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                  ),
                  child: Column(
                    children: [
                      // Level
                      const Text(
                        "A1 Level",
                        style: TextStyle(color: Colors.white38),
                      ),

                      const SizedBox(height: 10),

                      // Word
                      Text(
                        word.word,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Pronunciation
                      Text(
                        "[${word.pronunciation}]",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── EYE / TRANSLATION AREA ──────────────
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleTranslation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF141A26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: showTranslation
                                    ? Text(
                                        word.translation,
                                        key: const ValueKey("text"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.visibility_outlined,
                                        key: ValueKey("icon"),
                                        color: Colors.white38,
                                        size: 40,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── BUTTONS ──────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              label: "I Know",
                              onTap: _selectKnow,
                              active: mode == "know",
                              activeColor: const Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildButton(
                              label: "Learn",
                              onTap: _selectLearn,
                              active: mode == "learn",
                              activeColor: const Color(0xFFFF5A5F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required bool active,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? activeColor : Colors.transparent,
          border: active ? null : Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
