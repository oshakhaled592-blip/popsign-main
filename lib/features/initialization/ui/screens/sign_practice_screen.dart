import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/services/translation_service.dart';
import '../../../../core/models/prediction_model.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/language_notifier.dart';

class SignPracticeScreen extends StatefulWidget {
  final String targetWord;
  final String videoUrl;

  const SignPracticeScreen({
    super.key,
    required this.targetWord,
    this.videoUrl = '',
  });

  @override
  State<SignPracticeScreen> createState() => _SignPracticeScreenState();
}

enum _PracticeStatus { idle, loading, correct, wrong }

class _SignPracticeScreenState extends State<SignPracticeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _service = TranslationService();

  _PracticeStatus _status = _PracticeStatus.idle;
  PredictionResult? _result;
  String _error = '';
  bool _videoWatched = false;
  bool _waitingForVideoReturn = false;

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  late AnimationController _celebController;
  late Animation<double> _celebAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    languageNotifier.addListener(_rebuild);
    _celebController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebAnim = CurvedAnimation(parent: _celebController, curve: Curves.elasticOut);
  }

  void _rebuild() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForVideoReturn) {
      _waitingForVideoReturn = false;
      if (mounted) setState(() => _videoWatched = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    languageNotifier.removeListener(_rebuild);
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
    final camera = await Permission.camera.request();
    if (!camera.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.get('storage_permission_required')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF2F4FA);
    final cardBg = isDark ? const Color(0xFF141829) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg = isDark ? const Color(0xFF1E1F35) : Colors.white;

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
                    onTap: () => Navigator.pop(context, _videoWatched ? 'done' : false),
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
                    child: Text(S.get('practice_sign_title'), textAlign: TextAlign.center,
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
                            child: Text(S.get('sign_this_word'),
                                style: TextStyle(color: const Color(0xFF22C55E),
                                    fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: 14.h),
                          Text(widget.targetWord,
                              style: TextStyle(color: textColor, fontSize: 40.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          Text(S.get('sign_word_instructions'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: subColor, fontSize: 13.sp, height: 1.5)),
                        ],
                      ),
                    ),

                    // tutorial video card
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () async {
                        String urlStr = widget.videoUrl.isNotEmpty
                            ? widget.videoUrl
                            : 'https://www.youtube.com/results?search_query=sign+language+${Uri.encodeComponent(widget.targetWord)}';

                        // Convert watch/short URLs to embed URLs so Chrome Custom Tab
                        // handles them instead of handing off to the YouTube app.
                        // YouTube app won't intercept embed paths, so back returns here.
                        final videoId = RegExp(
                          r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)',
                        ).firstMatch(urlStr)?.group(1);
                        if (videoId != null) {
                          urlStr = 'https://www.youtube.com/embed/$videoId';
                        }

                        final uri = Uri.parse(urlStr);
                        if (await canLaunchUrl(uri)) {
                          _waitingForVideoReturn = true;
                          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.18 : 0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 28.sp),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.videoUrl.isNotEmpty
                                        ? 'Watch Tutorial'
                                        : 'Search Tutorial on YouTube',
                                    style: TextStyle(
                                      color: const Color(0xFF7C3AED),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'See how to sign "${widget.targetWord}"',
                                    style: TextStyle(color: subColor, fontSize: 12.sp),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.open_in_new_rounded,
                                color: const Color(0xFF7C3AED), size: 18.sp),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // recorded video preview
                    if (_videoReady && _videoController != null)
                      Center(
                        child: SizedBox(
                          width: 220.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
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
                                    strokeWidth: 2.5, color: Color(0xFF7C3AED))),
                            SizedBox(width: 12.w),
                            Text(S.get('analyzing'),
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
                              Text(S.get('correct_title'), style: TextStyle(color: Colors.green,
                                  fontSize: 24.sp, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4.h),
                              Text(S.get('signed_correctly').replaceAll('{word}', widget.targetWord),
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
                            Text(S.get('not_quite_title'), style: TextStyle(color: Colors.red,
                                fontSize: 20.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _badge(S.get('expected_label'), widget.targetWord, Colors.green, isDark),
                                SizedBox(width: 12.w),
                                _badge(S.get('got_label'), _result!.top.label, Colors.red, isDark),
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
                    _btn(S.get('done_check'), Colors.green, () => Navigator.pop(context, true)),
                  if (_status == _PracticeStatus.wrong) ...[
                    _btn(S.get('try_again'), const Color(0xFF7C3AED), () {
                      setState(() {
                        _status = _PracticeStatus.idle;
                        _result = null;
                        _videoController?.dispose();
                        _videoController = null;
                        _videoReady = false;
                      });
                      _pickAndPredict(ImageSource.camera);
                    }),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Text(S.get('skip_for_now'),
                          style: TextStyle(color: subColor, fontSize: 14.sp)),
                    ),
                  ],
                  if (_status == _PracticeStatus.idle) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _btn(S.get('record_video'), const Color(0xFF7C3AED),
                              () => _pickAndPredict(ImageSource.camera)),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _btn(S.get('upload_video'), const Color(0xFF0EA5E9),
                              () => _pickAndPredict(ImageSource.gallery)),
                        ),
                      ],
                    ),
                    if (_videoWatched) ...[
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.green, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text('I know this sign',
                                style: TextStyle(color: Colors.green, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ],
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
