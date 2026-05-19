import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/data/word_data.dart';
import 'package:popsign/core/l10n/app_strings.dart';
import 'package:popsign/core/routing/routes.dart';
import 'package:popsign/core/theme/language_notifier.dart';
import 'package:popsign/core/widgets/linear_button.dart';
import 'word_list_screen.dart';

class PreStartScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedCategory;

  const PreStartScreen({super.key, this.selectedCategory});

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
    languageNotifier.addListener(_rebuild);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade  = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  String get _level => widget.selectedCategory?['level'] as String? ?? 'A1';

  static const _levelColors = {
    'A1': [Color(0xFF0BA58D), Color(0xFF1EC9B4)],
    'A2': [Color(0xFF5E9E10), Color(0xFF83D61B)],
    'B1': [Color(0xFF9E8010), Color(0xFFD4AC0D)],
    'B2': [Color(0xFFB85A05), Color(0xFFD96C06)],
    'C1': [Color(0xFFDD4511), Color(0xFFFF5722)],
    'C2': [Color(0xFFC2185B), Color(0xFFE91E63)],
  };

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? const Color(0xFF0B0F18) : const Color(0xFFF2F4FA);
    final cardBg   = isDark ? const Color(0xFF141A29) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg     = isDark ? const Color(0xFF1E2538) : Colors.white;
    final btnIcon   = isDark ? Colors.white70 : const Color(0xFF1A1A2E);
    final divColor  = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade200;

    final colors = _levelColors[_level] ?? _levelColors['A1']!;
    final words  = getWords(languageNotifier.value.code, _level);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconBtn(Icons.arrow_back_ios_new_rounded,
                          bg: btnBg, iconColor: btnIcon,
                          onTap: () => Navigator.pop(context)),

                      Text(
                        S.get('pre_start'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _iconBtn(Icons.menu_rounded,
                          bg: btnBg, iconColor: btnIcon,
                          onTap: () => Navigator.pushNamed(context, Routes.profile)),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _level,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${words.length} words',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              const {
                                'A1': '1 – 100 words',
                                'A2': '101 – 1k words',
                                'B1': '1k – 2k words',
                                'B2': '2k – 3k words',
                                'C1': '3k – 4k words',
                                'C2': '4k – 5k words',
                              }[_level] ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: words.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: divColor),
                    itemBuilder: (_, i) {
                      return Container(
                        color: cardBg,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(
                                (i + 1).toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: subColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                words[i],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Column(
                    children: [
                      LinearButton(
                        text: S.get('start_learning'),
                        icon: Icons.auto_stories_rounded,
                        width: double.infinity,
                        height: 54.h,
                        radius: 16.r,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordListScreen(level: _level),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon,
      {required Color bg, required Color iconColor, VoidCallback? onTap}) {
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
}
