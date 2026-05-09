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
      duration: const Duration(milliseconds: 900),
    );
    _fade  = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg        = isDark ? const Color(0xFF0B0F18) : const Color(0xFFD8DCE8);
    final cardBg    = isDark ? const Color(0xFF141A29) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg     = isDark ? const Color(0xFF1E2538) : Colors.white;
    final btnIcon   = isDark ? Colors.white70 : const Color(0xFF1A1A2E);

    final cardShadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  // ── HEADER ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _btn(Icons.arrow_back_ios_new_rounded,
                          bg: btnBg, iconColor: btnIcon,
                          onTap: () => Navigator.pop(context)),

                      Text(
                        "Pre-start",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _btn(Icons.menu_rounded,
                          bg: btnBg, iconColor: btnIcon,
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.profile)),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // ── LEVEL CARDS ────────────────────────────────
                  _levelCard(
                    isDark: isDark,
                    cardBg: cardBg,
                    shadow: cardShadow,
                    textColor: textColor,
                    subColor: subColor,
                    color1: const Color(0xFF0BA58D),
                    color2: const Color(0xFF1EC9B4),
                    title: "A1",
                    subtitle: "1–100 words",
                    percent: "80%",
                  ),

                  const SizedBox(height: 14),

                  _levelCard(
                    isDark: isDark,
                    cardBg: cardBg,
                    shadow: cardShadow,
                    textColor: textColor,
                    subColor: subColor,
                    color1: const Color(0xFF5E9E10),
                    color2: const Color(0xFF83D61B),
                    title: "A2",
                    subtitle: "101–1k words",
                    percent: "44%",
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Customize your progress if you wish",
                    style: TextStyle(color: subColor, fontSize: 14),
                  ),

                  const Spacer(),

                  // ── START BUTTON ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.wordList),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Start learning",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Home indicator bar
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white24
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon,
      {required Color bg,
      required Color iconColor,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _levelCard({
    required bool isDark,
    required Color cardBg,
    required List<BoxShadow> shadow,
    required Color textColor,
    required Color subColor,
    required Color color1,
    required Color color2,
    required String title,
    required String subtitle,
    required String percent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadow,
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.05))
            : null,
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 44,
            height: 34,
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
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            percent,
            style: TextStyle(
              color: subColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 8),

          Icon(Icons.chevron_right_rounded, color: subColor, size: 20),
        ],
      ),
    );
  }
}
