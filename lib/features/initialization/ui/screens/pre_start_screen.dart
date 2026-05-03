import 'package:flutter/material.dart';
import 'package:popsign/core/routing/routes.dart';

class PreStartScreen extends StatefulWidget {
  const PreStartScreen({super.key});

  @override
  State<PreStartScreen> createState() => _PreStartScreenState();
}

class _PreStartScreenState extends State<PreStartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E18),

      body: Stack(
        children: [
          /// Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/start-image.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double scale = constraints.maxWidth / 390;

                      return Column(
                        children: [
                          SizedBox(height: 14 * scale),

                          /// Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleBtn(
                                Icons.arrow_back_ios_new_rounded,
                                onTap: () => Navigator.pop(context),
                              ),

                              const Text(
                                "Pre-start",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              /// 🔥 الزرار ده يفتح Profile
                              _circleBtn(
                                Icons.menu_rounded,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.profile,
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 56 * scale),

                          /// Card A1
                          _levelCard(
                            color1: const Color(0xFF0BA58D),
                            color2: const Color(0xFF1EC9B4),
                            title: "A1",
                            subtitle: "1-100 words",
                            percent: "80%",
                          ),

                          SizedBox(height: 16 * scale),

                          /// Card A2
                          _levelCard(
                            color1: const Color(0xFF5E9E10),
                            color2: const Color(0xFF83D61B),
                            title: "A2",
                            subtitle: "101 - 1k words",
                            percent: "44%",
                          ),

                          SizedBox(height: 28 * scale),

                          const Text(
                            "Customize your progress if you wish",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                            ),
                          ),

                          const Spacer(),

                          /// START BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.wordList,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE1A1A7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Start learning",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          /// Bottom line
                          Container(
                            width: 134,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),

                          SizedBox(height: 10 * scale),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF171C2B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  /// Level card
  Widget _levelCard({
    required Color color1,
    required Color color2,
    required String title,
    required String subtitle,
    required String percent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141A29),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color1, color2]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          Text(
            percent,
            style: const TextStyle(color: Colors.white38),
          ),

          const SizedBox(width: 10),

          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}