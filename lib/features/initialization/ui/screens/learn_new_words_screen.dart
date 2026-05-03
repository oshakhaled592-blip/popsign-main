import 'package:flutter/material.dart';
import 'package:popsign/core/routing/routes.dart';

class LearnNewWordsScreen extends StatefulWidget {
  final String word;
  final String image;

  const LearnNewWordsScreen({
    super.key,
    required this.word,
    required this.image,
  });

  @override
  State<LearnNewWordsScreen> createState() =>
      _LearnNewWordsScreenState();
}

class _LearnNewWordsScreenState extends State<LearnNewWordsScreen>
    with SingleTickerProviderStateMixin {
  bool showTranslation = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  static const Map<String, String> _pronunciations = {
    'mother': "ˈmʌðə",
    'father': "ˈfɑːðə",
    'brother': "ˈbrʌðə",
    'sister': "ˈsɪstə",
  };

  static const Map<String, String> _translations = {
    'mother': 'mama',
    'father': 'papa',
    'brother': 'akh',
    'sister': 'okht',
  };

  String _getPronunciation(String word) =>
      _pronunciations[word.toLowerCase()] ?? word;

  String _getTranslation(String word) =>
      _translations[word.toLowerCase()] ?? word;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.93, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  void _toggleTranslation() {
    setState(() => showTranslation = !showTranslation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _circleBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF171C2B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildButton(String text,
      {bool isPrimary = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isPrimary ? const Color(0xFF22C55E) : null,
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.08)),
          gradient: isPrimary
              ? null
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  isPrimary ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              /// 🔥 HEADER الجديد
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleBtn(
                    Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Learn",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _circleBtn(
                    Icons.menu_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.profile);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
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
                              "[${_getPronunciation(widget.word)}]",
                              style: const TextStyle(
                                  color: Colors.white38),
                            ),

                            const SizedBox(height: 20),

                            /// 👁️ CARD
                            Expanded(
                              child: GestureDetector(
                                onTap: _toggleTranslation,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141A26),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: showTranslation
                                          ? Text(
                                              _getTranslation(widget.word),
                                              key: const ValueKey("text"),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight:
                                                    FontWeight.bold,
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

                            /// 🔘 BUTTONS
                            Row(
                              children: [
                                Expanded(
                                  child: _buildButton(
                                    "I Know",
                                    isPrimary: true,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.iKnow,
                                        arguments: {
                                          'word': widget.word,
                                          'image': widget.image,
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildButton(
                                    "Learn",
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.learn,
                                      );
                                    },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}