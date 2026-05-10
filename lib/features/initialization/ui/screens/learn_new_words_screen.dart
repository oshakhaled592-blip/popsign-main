import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/theme/language_notifier.dart';

class WordItem {
  final String word;
  final String pronunciation;
  final String translation;

  const WordItem(this.word, this.pronunciation, this.translation);
}

class LearnNewWordsScreen extends StatefulWidget {
  final String? passedWord;
  final String level;

  const LearnNewWordsScreen({super.key, this.passedWord, this.level = 'A1'});

  @override
  State<LearnNewWordsScreen> createState() => _LearnNewWordsScreenState();
}

class _LearnNewWordsScreenState extends State<LearnNewWordsScreen>
    with SingleTickerProviderStateMixin {
  bool showTranslation = false;
  String mode = "none"; // "none" | "know" | "learn"

  late AnimationController _tiltController;
  late Animation<double> _tiltAnim;
  double _tiltDirection = 0; // +1 right, -1 left

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
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _tiltAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeOut),
    );
    if (widget.passedWord != null) {
      words = [WordItem(widget.passedWord!, '', '')];
    } else {
      words = List.of(_base)..shuffle();
    }
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _tilt(double direction) {
    _tiltController.stop();
    _tiltDirection = direction;
    _tiltController.reset();
    _tiltController.forward().then((_) {
      if (mounted) _tiltController.reverse();
    });
  }

  void _toggleTranslation() {
    HapticFeedback.selectionClick();
    setState(() => showTranslation = !showTranslation);
  }

  void _selectKnow() {
    HapticFeedback.lightImpact();
    setState(() => mode = "know");
    _tilt(-1);
  }

  void _selectLearn() {
    HapticFeedback.heavyImpact();
    setState(() => mode = "learn");
    _tilt(1);
  }

  // card gradient based on mode
  List<Color> get _cardColors {
    return [const Color(0xFF18202E), const Color(0xFF10141F)];
  }

  // inner reveal box color
  Color get _revealBg => const Color(0xFF141A26);

  @override
  Widget build(BuildContext context) {
    final word = words[currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final revealText = word.translation.isNotEmpty ? word.translation : word.word;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // ── HEADER ────────────────────────────────────────
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
                    child: ValueListenableBuilder<LanguageInfo>(
                      valueListenable: languageNotifier,
                      builder: (_, __, ___) => Text(
                        S.get('learn_words'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),

              const SizedBox(height: 20),

              // ── CARD ──────────────────────────────────────────
              Expanded(
                child: AnimatedBuilder(
                  animation: _tiltAnim,
                  builder: (context, child) => Transform.rotate(
                    angle: _tiltAnim.value * 0.13 * _tiltDirection,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _cardColors,
                      ),
                      boxShadow: mode == "know"
                          ? [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(
                                  alpha: isDark ? 0.25 : 0.55,
                                ),
                                blurRadius: isDark ? 28 : 36,
                                spreadRadius: isDark ? 2 : 5,
                              ),
                            ]
                          : mode == "learn"
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withValues(
                                      alpha: isDark ? 0.25 : 0.55,
                                    ),
                                    blurRadius: isDark ? 28 : 36,
                                    spreadRadius: isDark ? 2 : 5,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                    ),
                    child: Column(
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${widget.level} Level",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Word
                        Text(
                          word.word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (word.pronunciation.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            "[${word.pronunciation}]",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── REVEAL AREA ────────────────────────────
                        Expanded(
                          child: GestureDetector(
                            onTap: _toggleTranslation,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              decoration: BoxDecoration(
                                color: _revealBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: showTranslation
                                      ? Text(
                                          revealText,
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

                        // ── BUTTONS ────────────────────────────────
                        ValueListenableBuilder<LanguageInfo>(
                          valueListenable: languageNotifier,
                          builder: (_, __, ___) => Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: S.get('i_know'),
                                  onTap: _selectKnow,
                                  active: mode == "know",
                                  color: const Color(0xFF22C55E),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildButton(
                                  label: S.get('learn'),
                                  onTap: _selectLearn,
                                  active: mode == "learn",
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
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
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? color : Colors.transparent,
          border: Border.all(
            color: active ? color : Colors.white24,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
