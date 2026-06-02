import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/services/translation_service.dart';
import '../../../../core/models/prediction_model.dart';

class SignPracticeScreen extends StatefulWidget {
  final String targetWord;

  const SignPracticeScreen({super.key, required this.targetWord});

  @override
  State<SignPracticeScreen> createState() => _SignPracticeScreenState();
}

enum _PracticeStatus { idle, loading, correct, wrong }

class _SignPracticeScreenState extends State<SignPracticeScreen>
    with SingleTickerProviderStateMixin {
  final _service = TranslationService();

  _PracticeStatus _status = _PracticeStatus.idle;
  PredictionResult? _result;
  String _error = '';

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  late AnimationController _celebController;
  late Animation<double> _celebAnim;

  @override
  void initState() {
    super.initState();
    _celebController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebAnim = CurvedAnimation(parent: _celebController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _celebController.dispose();
    super.dispose();
  }

  Future<void> _pickAndPredict(ImageSource source) async {
    final status = await _requestPermission();
    if (!status) return;

    final picked = await ImagePicker().pickVideo(source: source);
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    setState(() {
      _status = _PracticeStatus.loading;
      _videoReady = false;
    });

    await _initVideo(file);

    try {
      final result = await _service.predict(file);
      final matched = result.top.label.toLowerCase().trim() ==
          widget.targetWord.toLowerCase().trim();
      setState(() {
        _result = result;
        _status = matched ? _PracticeStatus.correct : _PracticeStatus.wrong;
      });
      if (matched) _celebController.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _status = _PracticeStatus.wrong;
      });
    }
  }

  Future<void> _initVideo(File file) async {
    await _videoController?.dispose();
    _videoController = VideoPlayerController.file(file);
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    if (mounted) setState(() => _videoReady = true);
  }

  Future<bool> _requestPermission() async {
    if (await Permission.videos.isGranted) return true;
    if (await Permission.storage.isGranted) return true;
    final v = await Permission.videos.request();
    if (v.isGranted) return true;
    final s = await Permission.storage.request();
    return s.isGranted;
  }

  void _showSourcePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141A29) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 20.h),
              _srcBtn(Icons.video_library_rounded, 'Choose from Gallery',
                  () { Navigator.pop(context); _pickAndPredict(ImageSource.gallery); }, isDark),
              SizedBox(height: 12.h),
              _srcBtn(Icons.videocam_rounded, 'Record a Video',
                  () { Navigator.pop(context); _pickAndPredict(ImageSource.camera); }, isDark),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _srcBtn(IconData icon, String label, VoidCallback onTap, bool isDark) {
    const purple = Color(0xFF6C63FF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: isDark ? 0.1 : 0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: purple.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: purple, size: 22.sp),
            SizedBox(width: 14.w),
            Text(label,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 15.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
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
        child: Column(
          children: [
            // header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      width: 44.w, height: 44.h,
                      decoration: BoxDecoration(
                        color: btnBg,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18.sp),
                    ),
                  ),
                  Expanded(
                    child: Text('Practice Sign', textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // target word card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 24.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: 0.08),
                              blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text('Sign this word',
                                style: TextStyle(color: const Color(0xFF22C55E),
                                    fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: 14.h),
                          Text(widget.targetWord,
                              style: TextStyle(color: textColor, fontSize: 40.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          Text('Sign the word above, then upload your video',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: subColor, fontSize: 13.sp, height: 1.5)),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // video preview
                    if (_videoReady && _videoController != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: SizedBox(
                          width: double.infinity,
                          height: 200.h,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController!.value.size.width,
                              height: _videoController!.value.size.height,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        ),
                      ),

                    if (_videoReady) SizedBox(height: 20.h),

                    // result
                    if (_status == _PracticeStatus.loading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20.w, height: 20.w,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Color(0xFF6C63FF))),
                            SizedBox(width: 12.w),
                            Text('Analyzing…',
                                style: TextStyle(color: textColor, fontSize: 16.sp,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),

                    if (_status == _PracticeStatus.correct)
                      ScaleTransition(
                        scale: _celebAnim,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.green, size: 52.sp),
                              SizedBox(height: 10.h),
                              Text('Correct!', style: TextStyle(color: Colors.green,
                                  fontSize: 24.sp, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4.h),
                              Text('You signed "${widget.targetWord}" correctly!',
                                  style: TextStyle(color: subColor, fontSize: 13.sp)),
                            ],
                          ),
                        ),
                      ),

                    if (_status == _PracticeStatus.wrong && _result != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cancel_rounded, color: Colors.red, size: 48.sp),
                            SizedBox(height: 10.h),
                            Text('Not quite!', style: TextStyle(color: Colors.red,
                                fontSize: 20.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _badge('Expected', widget.targetWord, Colors.green, isDark),
                                SizedBox(width: 12.w),
                                _badge('Got', _result!.top.label, Colors.red, isDark),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (_status == _PracticeStatus.wrong && _result == null && _error.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(_error, textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 13.sp)),
                      ),
                  ],
                ),
              ),
            ),

            // bottom buttons
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Column(
                children: [
                  if (_status == _PracticeStatus.correct)
                    _btn('Done ✓', Colors.green, () => Navigator.pop(context, true)),
                  if (_status == _PracticeStatus.wrong) ...[
                    _btn('Try Again', const Color(0xFF6C63FF), () {
                      setState(() {
                        _status = _PracticeStatus.idle;
                        _result = null;
                        _videoController?.dispose();
                        _videoController = null;
                        _videoReady = false;
                      });
                      _showSourcePicker();
                    }),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Text('Skip for now',
                          style: TextStyle(color: subColor, fontSize: 14.sp)),
                    ),
                  ],
                  if (_status == _PracticeStatus.idle)
                    _btn('Upload Video', const Color(0xFF6C63FF), _showSourcePicker),
                  SizedBox(height: 12.h),
                  Container(
                    width: 120.w, height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _badge(String title, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11.sp)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(value,
              style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
