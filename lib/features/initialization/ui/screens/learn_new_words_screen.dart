import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';

class LearnNewWordsScreen extends StatefulWidget {
  const LearnNewWordsScreen({super.key});

  @override
  State<LearnNewWordsScreen> createState() =>
      _LearnNewWordsScreenState();
}

/// 🧠 MODEL
class WordItem {
  final String word;
  final String translation;

  WordItem(this.word, this.translation);
}

class _LearnNewWordsScreenState
    extends State<LearnNewWordsScreen> {
  bool showTranslation = false;
  String mode = "none";

  double rotateX = 0;
  double rotateY = 0;

  int currentIndex = 0;
  int correct = 0;

  late List<WordItem> words;

  Map<String, int> score = {};

  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();

    words = _buildSmartQueue([
      WordItem("mother", "mama"),
      WordItem("father", "papa"),
      WordItem("brother", "akh"),
      WordItem("sister", "okht"),
    ]);

    _confetti = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  List<WordItem> _buildSmartQueue(List<WordItem> base) {
    final list = <WordItem>[];

    for (var w in base) {
      final s = score[w.word] ?? 0;

      int repeat = s <= 0 ? 3 : (s == 1 ? 2 : 1);

      for (int i = 0; i < repeat; i++) {
        list.add(w);
      }
    }

    list.shuffle();
    return list;
  }

  void toggleTranslation() {
    setState(() => showTranslation = !showTranslation);
  }

  void resetTilt() {
    setState(() {
      rotateX = 0;
      rotateY = 0;
    });
  }

  void nextWord() {
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        showTranslation = false;
        mode = "none";
        rotateX = 0;
        rotateY = 0;
      });
    } else {
      debugPrint("Finished 🎉");
    }
  }

  Future<void> vibrate(bool strong) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: strong ? 60 : 30);
    }
  }

  void selectKnow() {
    final word = words[currentIndex].word;

    score[word] = (score[word] ?? 0) + 1;
    correct++;

    _confetti.play();
    vibrate(false);

    setState(() {
      mode = "know";
      rotateY = 0.15;
    });

    Future.delayed(const Duration(milliseconds: 400), nextWord);
  }

  void selectLearn() {
    final word = words[currentIndex].word;

    score[word] = (score[word] ?? 0) - 1;

    vibrate(true);

    setState(() {
      mode = "learn";
      rotateY = -0.15;
    });

    Future.delayed(const Duration(milliseconds: 400), nextWord);
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = words[currentIndex];

    double progress = (currentIndex + 1) / words.length;

    Color glowColor = Colors.transparent;
    if (mode == "learn") glowColor = Colors.red;
    if (mode == "know") glowColor = Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              /// 🎯 PROGRESS
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white12,
                color: Colors.green,
                minHeight: 6,
              ),

              const SizedBox(height: 10),

              Text(
                "${currentIndex + 1} / ${words.length}",
                style: const TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 20),

              /// 🎉 CONFETTI
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality:
                      BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
              ),

              /// 🔥 3D CARD
              Expanded(
                child: GestureDetector(
                  onTap: toggleTranslation,

                  onPanUpdate: (details) {
                    setState(() {
                      rotateY += details.delta.dx * 0.005;
                      rotateX -= details.delta.dy * 0.005;
                    });
                  },

                  onPanEnd: (_) => resetTilt(),

                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      selectLearn();
                    } else {
                      selectKnow();
                    }
                  },

                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateX(rotateX)
                      ..rotateY(rotateY),
                    child: Stack(
                      children: [
                        /// 🌈 GLOW
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: glowColor.withOpacity(0.6),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// 🟦 CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF18202E),
                                Color(0xFF10141F)
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text("A1 Level",
                                  style: TextStyle(
                                      color: Colors.white38)),

                              const SizedBox(height: 10),

                              /// 🧠 PARALLAX WORD
                              Transform.translate(
                                offset: Offset(
                                    rotateY * 40, rotateX * 40),
                                child: Text(
                                  currentWord.word,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// 👁️ CARD
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      /// 🌫️ BLUR
                                      BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX:
                                              (rotateX.abs() +
                                                      rotateY.abs()) *
                                                  10,
                                          sigmaY:
                                              (rotateX.abs() +
                                                      rotateY.abs()) *
                                                  10,
                                        ),
                                        child: Container(
                                          color: Colors.transparent,
                                        ),
                                      ),

                                      Center(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          child: showTranslation
                                              ? Text(
                                                  currentWord
                                                      .translation,
                                                  key:
                                                      const ValueKey(
                                                          "text"),
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons
                                                      .visibility_outlined,
                                                  key: ValueKey(
                                                      "icon"),
                                                  color:
                                                      Colors.white38,
                                                  size: 40,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// 🔘 BUTTONS
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: selectKnow,
                                      child: Container(
                                        height: 55,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  16),
                                          color: mode == "know"
                                              ? const Color(
                                                  0xFF22C55E)
                                              : Colors.transparent,
                                          border: Border.all(
                                              color:
                                                  Colors.white24),
                                        ),
                                        child: const Center(
                                          child: Text("I Know",
                                              style: TextStyle(
                                                  color: Colors
                                                      .white)),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: GestureDetector(
                                      onTap: selectLearn,
                                      child: Container(
                                        height: 55,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  16),
                                          color: mode == "learn"
                                              ? const Color(
                                                  0xFFFF4D4D)
                                              : Colors.transparent,
                                          border: Border.all(
                                              color:
                                                  Colors.white24),
                                        ),
                                        child: const Center(
                                          child: Text("Learn",
                                              style: TextStyle(
                                                  color: Colors
                                                      .white)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
}