import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popsign/core/routing/routes.dart';

enum _State { idle, loading, result }

class LostPage extends StatefulWidget {
  const LostPage({super.key});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage>
    with SingleTickerProviderStateMixin {
  _State _state = _State.idle;
  String _translation = '';
  // ignore: unused_field
  File? _videoFile;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    setState(() {
      _videoFile = File(picked.path);
      _state = _State.loading;
      _translation = '';
    });

    // TODO: send _videoFile to your sign-language model API and get translation
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _translation = 'Hello';
      _state = _State.result;
    });
  }

  void _reset() {
    setState(() {
      _state = _State.idle;
      _translation = '';
      _videoFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B0F18) : const Color(0xFFF2F4FA);
    final cardBg = isDark ? const Color(0xFF141A29) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg = isDark ? const Color(0xFF1E2538) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── HEADER ──────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: btnBg,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: textColor, size: 18),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      'Translate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.profile),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: btnBg,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.menu_rounded,
                          color: textColor, size: 20),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── MAIN CONTENT ─────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: switch (_state) {
                  _State.idle    => _buildIdle(cardBg, textColor, subColor),
                  _State.loading => _buildLoading(textColor, subColor),
                  _State.result  => _buildResult(cardBg, textColor, subColor),
                },
              ),

              const Spacer(),

              // ── BOTTOM BUTTON ─────────────────────────────────────
              if (_state == _State.idle || _state == _State.result)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _state == _State.result
                      ? _gradientButton(
                          key: const ValueKey('new'),
                          label: 'Upload new video',
                          icon: Icons.video_call_rounded,
                          onTap: _reset,
                        )
                      : _gradientButton(
                          key: const ValueKey('upload'),
                          label: 'Upload your video',
                          icon: Icons.upload_rounded,
                          onTap: _pickVideo,
                        ),
                ),

              const SizedBox(height: 12),

              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdle(Color cardBg, Color textColor, Color subColor) {
    return Column(
      key: const ValueKey('idle'),
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_camera_back_rounded,
              size: 52,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Upload your video',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Record or choose a sign-language\nvideo to get the translation',
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLoading(Color textColor, Color subColor) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Analyzing video…',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'The model is processing\nyour sign language',
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildResult(Color cardBg, Color textColor, Color subColor) {
    return Column(
      key: const ValueKey('result'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Translation',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _translation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradientButton({
    required Key key,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
