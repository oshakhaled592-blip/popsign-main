
import 'package:flutter/material.dart';

class IKnowScreen extends StatefulWidget {
  final String word;
  final String image;

  const IKnowScreen({
    super.key,
    required this.word,
    required this.image,
  });

  @override
  State<IKnowScreen> createState() => _IKnowScreenState();
}

class _IKnowScreenState extends State<IKnowScreen>
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

  String get pronunciation =>
      _pronunciations[widget.word.toLowerCase()] ?? widget.word;

  String get translation =>
      _translations[widget.word.toLowerCase()] ?? widget.word;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _scale = Tween<double>(begin: 0.93, end: 1).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  void toggleTranslation() {
    setState(() => showTranslation = !showTranslation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              /// 🔝 HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "I Know",
                    style:
                        TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🟦 CARD
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
                              "[$pronunciation]",
                              style: const TextStyle(
                                  color: Colors.white38),
                            ),

                            const SizedBox(height: 20),

                            /// 👁️ CARD
                            Expanded(
                              child: GestureDetector(
                                onTap: toggleTranslation,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141A26),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      /// 👁️ icon
                                      AnimatedOpacity(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        opacity:
                                            showTranslation ? 0 : 1,
                                        child: const Center(
                                          child: Icon(
                                            Icons
                                                .visibility_outlined,
                                            color: Colors.white38,
                                            size: 40,
                                          ),
                                        ),
                                      ),

                                      /// 🔥 translation
                                      AnimatedOpacity(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        opacity:
                                            showTranslation ? 1 : 0,
                                        child: Center(
                                          child: Text(
                                            translation,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight:
                                                  FontWeight.bold,
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

                            /// 🔘 BUTTONS (زي شاشة Learn)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildButton(
                                    "I Know",
                                    isPrimary: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildButton(
                                    "Learn",
                                    onTap: () {
                                      Navigator.pop(context);
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