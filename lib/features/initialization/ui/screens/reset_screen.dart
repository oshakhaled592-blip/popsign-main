import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popsign/core/l10n/app_strings.dart';

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade  = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C2333) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white54 : Colors.grey.shade600;
    final divColor  = isDark ? Colors.white12 : Colors.grey.shade200;

    // read strings at show-time so they match current language
    final title    = S.get('reset_title');
    final body     = S.get('reset_body');
    final cancel   = S.get('cancel');
    final resetLbl = S.get('reset_all');

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 28),

                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: subColor,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Divider(height: 1, color: divColor),

                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context, false);
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                cancel,
                                style: GoogleFonts.poppins(
                                  color: subColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(width: 1, height: 52, color: divColor),

                      // Reset
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          },
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                resetLbl,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
