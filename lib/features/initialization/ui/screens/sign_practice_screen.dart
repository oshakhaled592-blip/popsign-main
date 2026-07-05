import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/services/translation_service.dart';
import '../../../../core/models/prediction_model.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/language_notifier.dart';

class SignPracticeScreen extends StatefulWidget {
  final String targetWord;
  final String videoUrl;
  final String englishWord;

  const SignPracticeScreen({
    super.key,
    required this.targetWord,
    this.videoUrl = '',
    this.englishWord = '',
  });

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
  bool _videoWatched = false;

  VideoPlayerController? _videoController;
  bool _videoReady = false;
  VideoPlayerController? _tutorialController;
  bool _tutorialReady = false;
  String? _videoId;
  YoutubePlayerController? _ytController;
  StreamSubscription<YoutubePlayerValue>? _ytStateSub;

  late AnimationController _celebController;
  late Animation<double> _celebAnim;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
    _celebController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebAnim = CurvedAnimation(parent: _celebController, curve: Curves.elasticOut);

    _videoId = _extractVideoId(widget.videoUrl);
    _initTutorialVideo();
  }

  Future<void> _initTutorialVideo() async {
    final word = (widget.englishWord.isNotEmpty ? widget.englishWord : widget.targetWord)
        .toLowerCase()
        .trim();
    final assetPath = 'assets/videos/$word.mp4';
    try {
      await rootBundle.load(assetPath);
      final ctrl = VideoPlayerController.asset(assetPath);
      await ctrl.initialize();
      ctrl.setLooping(true);
      if (!mounted) { ctrl.dispose(); return; }
      ctrl.addListener(_onTutorialProgress);
      setState(() {
        _tutorialController = ctrl;
        _tutorialReady = true;
      });
    } catch (_) {
      if (_videoId == null || !mounted) return;
      final yt = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          playsInline: true,
          showFullscreenButton: true,
          showVideoAnnotations: false,
          enableCaption: false,
          strictRelatedVideos: true,
        ),
      );
      _ytStateSub = yt.listen((value) {
        if (!_videoWatched && value.playerState == PlayerState.playing) {
          setState(() => _videoWatched = true);
        }
      });
      setState(() {
        _ytController = yt;
      });
    }
  }

  // Marks the tutorial as watched the first time playback actually advances.
  void _onTutorialProgress() {
    if (_videoWatched) return;
    final value = _tutorialController?.value;
    if (value != null && value.isInitialized && value.position > Duration.zero) {
      setState(() => _videoWatched = true);
    }
  }

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;
    final patterns = [
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(url);
      if (m != null) return m.group(1);
    }
    return null;
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _videoController?.dispose();
    _tutorialController?.removeListener(_onTutorialProgress);
    _tutorialController?.dispose();
    _ytStateSub?.cancel();
    _ytController?.close();
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
      final target = (widget.englishWord.isNotEmpty ? widget.englishWord : widget.targetWord)
          .toLowerCase()
          .trim();
      final matched = result.predictions.any(
        (p) => p.label.toLowerCase().trim() == target,
      );
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
    final mic = await Permission.microphone.request();
    if (!camera.isGranted || !mic.isGranted) {
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

  // What to report back to the word list when this screen closes, so the
  // 3-dot progress (watched → tried → correct) advances no further than
  // what actually happened here.
  Object _currentResult() {
    if (_status == _PracticeStatus.correct) return true;
    if (_status == _PracticeStatus.wrong) return 'wrong';
    if (_videoWatched) return 'watched';
    return false;
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
                    onTap: () => Navigator.pop(context, _currentResult()),
                    child: Container(
                      width: 44.w, height: 44.h,
                      decoration: BoxDecoration(
                        color: btnBg,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8.r)],
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                  children: [
                    // unified word + tutorial card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.08),
                            blurRadius: 24.r,
                            spreadRadius: 2.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // word section
                          Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 18.h),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    S.get('sign_this_word'),
                                    style: TextStyle(
                                      color: const Color(0xFF22C55E),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  widget.targetWord,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 44.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  S.get('sign_word_instructions'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: subColor, fontSize: 12.sp, height: 1.5),
                                ),
                              ],
                            ),
                          ),

                          // divider with Tutorial label
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    height: 1,
                                    endIndent: 10.w,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.shade100,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.play_circle_outline_rounded,
                                        color: const Color(0xFF22C55E), size: 13.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Tutorial',
                                      style: TextStyle(
                                        color: const Color(0xFF22C55E),
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Divider(
                                    height: 1,
                                    indent: 10.w,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // video section — local asset first, YouTube fallback
                          if (_tutorialReady && _tutorialController != null)
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: AspectRatio(
                                  aspectRatio:
                                      _tutorialController!.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      VideoPlayer(_tutorialController!),
                                      _VideoPlayPause(
                                          controller: _tutorialController!),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (_ytController != null)
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: YoutubePlayer(
                                  controller: _ytController!,
                                  aspectRatio: 16 / 9,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 18.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_library_outlined,
                                      color: subColor, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text('No tutorial available',
                                      style: TextStyle(
                                          color: subColor, fontSize: 13.sp)),
                                ],
                              ),
                            ),
                        ],
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
                        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
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
                            SizedBox(height: 12.h),
                            // Expected word
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green, size: 16.sp),
                                  SizedBox(width: 6.w),
                                  Text(S.get('expected_label'),
                                      style: TextStyle(color: Colors.green.withValues(alpha: 0.7), fontSize: 11.sp)),
                                  SizedBox(width: 6.w),
                                  Text(widget.targetWord,
                                      style: TextStyle(color: Colors.green, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            // Top-5 predictions
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(S.get('other_possibilities'),
                                  style: TextStyle(color: subColor, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(height: 8.h),
                            ..._result!.predictions.asMap().entries.map((e) {
                              final rank = e.key + 1;
                              final item = e.value;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22.w,
                                      height: 22.w,
                                      decoration: BoxDecoration(
                                        color: rank == 1
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : (isDark ? Colors.white10 : Colors.grey.shade200),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text('$rank',
                                            style: TextStyle(
                                              color: rank == 1 ? Colors.red : subColor,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(item.label,
                                          style: TextStyle(
                                            color: rank == 1 ? textColor : subColor,
                                            fontSize: 14.sp,
                                            fontWeight: rank == 1 ? FontWeight.w600 : FontWeight.normal,
                                          )),
                                    ),
                                    Text(item.percent,
                                        style: TextStyle(color: subColor, fontSize: 12.sp)),
                                  ],
                                ),
                              );
                            }),
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
                      onTap: () => Navigator.pop(context, 'wrong'),
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
                            Icon(Icons.check_circle_rounded, color: Colors.green, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(S.get('tutorial_watched'),
                                style: TextStyle(color: Colors.green, fontSize: 13.sp, fontWeight: FontWeight.w600)),
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
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16.r, offset: Offset(0, 6.h))],
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

}

class _VideoPlayPause extends StatefulWidget {
  const _VideoPlayPause({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_VideoPlayPause> createState() => _VideoPlayPauseState();
}

class _VideoPlayPauseState extends State<_VideoPlayPause> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final playing = widget.controller.value.isPlaying;
    return GestureDetector(
      onTap: () {
        playing ? widget.controller.pause() : widget.controller.play();
      },
      child: AnimatedOpacity(
        opacity: playing ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            color: Color(0xAA000000),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36.sp),
        ),
      ),
    );
  }
}
