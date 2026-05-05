import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

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
    HapticFeedback.selectionClick();
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

  void selectKnow() {
    final word = words[currentIndex].word;

    score[word] = (score[word] ?? 0) + 1;
    correct++;

    HapticFeedback.lightImpact();
    _confetti.play();

    setState(() {
      mode = "know";
      rotateY = 0.15;
    });

    Future.delayed(const Duration(milliseconds: 400), nextWord);
  }

  void selectLearn() {
    final word = words[currentIndex].word;

    score[word] = (score[word] ?? 0) - 1;

    HapticFeedback.heavyImpact();

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
              /// 🔝 HEADER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171C2B),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  const Text(
                    "Learn new words",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // TODO: open menu / profile
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171C2B),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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

              /// 🔥 CARD
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
                    child: Container(
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

                          Text(
                            currentWord.word,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Expanded(
                            child: Center(
                              child: showTranslation
                                  ? Text(
                                      currentWord.translation,
                                      style:
                                          const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                      ),
                                    )
                                  : const Icon(
                                      Icons
                                          .visibility_outlined,
                                      color:
                                          Colors.white38,
                                      size: 40,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: selectKnow,
                                  child: Container(
                                    height: 55,
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(16),
                                      border: Border.all(
                                          color: Colors
                                              .white24),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "I Know",
                                        style: TextStyle(
                                            color: Colors
                                                .white),
                                      ),
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
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(16),
                                      border: Border.all(
                                          color: Colors
                                              .white24),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Learn",
                                        style: TextStyle(
                                            color: Colors
                                                .white),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}