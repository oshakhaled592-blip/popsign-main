import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/models/prediction_model.dart';
import '../../../../core/state/translation_notifier.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/language_notifier.dart';

class LostPage extends StatefulWidget {
  const LostPage({super.key});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage>
    with SingleTickerProviderStateMixin {
  final _notifier = TranslationNotifier();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _notifier.addListener(_rebuild);
    _notifier.checkHealth();
    _notifier.loadClasses();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    _notifier.removeListener(_rebuild);
    _notifier.dispose();
    _pulseController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initVideo(File file) async {
    await _videoController?.dispose();
    _videoController = VideoPlayerController.file(file);
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    if (mounted) setState(() => _videoReady = true);
  }

  Future<void> _pickVideo(ImageSource source) async {
    final status = await _requestVideoPermission();
    if (!status) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.get('storage_permission_required')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final picked = await ImagePicker().pickVideo(source: source);
    if (picked == null || !mounted) return;
    final file = File(picked.path);
    setState(() => _videoReady = false);
    await _initVideo(file);
    await _notifier.predict(file);
  }

  Future<bool> _requestVideoPermission() async {
    // For camera recording, request camera permission
    final camera = await Permission.camera.request();
    if (camera.isGranted) return true;

    // For gallery, request storage/video permission
    if (await Permission.videos.isGranted) return true;
    if (await Permission.storage.isGranted) return true;
    final videos = await Permission.videos.request();
    if (videos.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  void _showSourcePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141829) : Colors.white,
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
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 20.h),
              _sourceOption(
                icon: Icons.video_library_rounded,
                label: S.get('choose_gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
              _sourceOption(
                icon: Icons.videocam_rounded,
                label: S.get('record_video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
                isDark: isDark,
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    const purple = Color(0xFF7C3AED);
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
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF2F4FA);
    final cardBg    = isDark ? const Color(0xFF141829) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg     = isDark ? const Color(0xFF1E1F35) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildHeader(textColor, btnBg),
            ),

            // sentence bar
            if (_notifier.sentence.isNotEmpty)
              _buildSentenceBar(cardBg, textColor, subColor, isDark),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: switch (_notifier.status) {
                    TranslationStatus.idle    => _buildIdle(textColor, subColor),
                    TranslationStatus.loading => _buildLoading(textColor, subColor, isDark),
                    TranslationStatus.success => _buildResult(cardBg, textColor, subColor, isDark),
                    TranslationStatus.error   => _buildError(textColor, subColor),
                  },
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Column(
                children: [
                  if (!_notifier.isLoading) _buildActionButton(isDark),
                  SizedBox(height: 12.h),
                  Container(
                    width: 120.w,
                    height: 4.h,
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

  Widget _buildHeader(Color textColor, Color btnBg) {
    final serverColor = switch (_notifier.serverStatus) {
      ServerStatus.online  => Colors.green,
      ServerStatus.offline => Colors.red,
      ServerStatus.unknown => Colors.orange,
    };

    return Row(
      children: [
        _iconBtn(Icons.arrow_back_ios_new_rounded, btnBg, textColor,
            () => Navigator.pop(context)),
        Expanded(
          child: Column(
            children: [
              Text(
                S.get('translate'),
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(color: serverColor, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    switch (_notifier.serverStatus) {
                      ServerStatus.online  => S.get('server_online'),
                      ServerStatus.offline => S.get('server_offline'),
                      ServerStatus.unknown => S.get('checking'),
                    },
                    style: TextStyle(color: serverColor, fontSize: 11.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
        _iconBtn(Icons.list_alt_rounded, btnBg, textColor, _showClasses),
      ],
    );
  }

  void _showClasses() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141829) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        final classes = _notifier.classes;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '${S.get('supported_signs')} (${classes.length})',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 16.sp, fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              if (_notifier.classesLoading)
                Padding(
                  padding: EdgeInsets.all(32.w),
                  child: const CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2),
                )
              else if (classes.isEmpty)
                Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Text(
                        S.get('could_not_load_classes'),
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14.sp),
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () => _notifier.loadClasses(),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(S.get('retry'), style: TextStyle(color: const Color(0xFF7C3AED), fontSize: 14.sp)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: classes.map((word) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              color: const Color(0xFF7C3AED),
                              fontSize: 13.sp, fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }

  Widget _buildIdle(Color textColor, Color subColor) {
    return Column(
      key: const ValueKey('idle'),
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.video_camera_back_rounded, size: 52.sp, color: const Color(0xFF7C3AED)),
          ),
        ),
        SizedBox(height: 24.h),
        Text(S.get('upload_your_video'),
            style: TextStyle(color: textColor, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        Text(
          S.get('record_or_choose_video'),
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 14.sp, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(bool isDark) {
    if (!_videoReady || _videoController == null) {
      return Container(
        width: double.infinity,
        height: 220.h,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1F35) : Colors.black12,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildLoading(Color textColor, Color subColor, bool isDark) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVideoPreview(isDark),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF7C3AED)),
            ),
            SizedBox(width: 12.w),
            Text(S.get('analyzing_video'),
                style: TextStyle(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          S.get('model_processing'),
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _buildResult(Color cardBg, Color textColor, Color subColor, bool isDark) {
    final result = _notifier.result!;
    final top    = result.top;
    const purple = Color(0xFF7C3AED);

    return SingleChildScrollView(
      key: const ValueKey('result'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVideoPreview(isDark),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(color: purple.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 2),
              ],
              border: Border.all(color: purple.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(S.get('translation_label'),
                      style: TextStyle(color: purple, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 12.h),
                Text(
                  top.label,
                  style: TextStyle(color: textColor, fontSize: 32.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${S.get('confidence_label')}  ${top.percent}',
                    style: TextStyle(color: Colors.green, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (result.predictions.length > 1) ...[
            SizedBox(height: 16.h),
            Text(S.get('other_possibilities'), style: TextStyle(color: subColor, fontSize: 13.sp)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: result.predictions.skip(1).map((PredictionItem p) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: isDark ? 0.1 : 0.07),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: purple.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${p.label}  ${p.percent}',
                    style: TextStyle(color: purple, fontSize: 13.sp, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(Color textColor, Color subColor) {
    return Column(
      key: const ValueKey('error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 40.sp),
        ),
        SizedBox(height: 20.h),
        Text(
          'Server Unavailable',
          style: TextStyle(color: textColor, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          'The AI server is temporarily offline.\nPlease try again in a few moments.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 13.sp, height: 1.6),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: () {
            _notifier.reset();
            _showSourcePicker();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: const Color(0xFF7C3AED),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceBar(Color cardBg, Color textColor, Color subColor, bool isDark) {
    const purple = Color(0xFF7C3AED);
    final sentence = _notifier.sentence;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(S.get('translation_label'),
                  style: TextStyle(color: purple, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _videoController?.dispose();
                  _videoController = null;
                  setState(() => _videoReady = false);
                  _notifier.clearSentence();
                },
                child: Text(S.get('clear_all'),
                    style: TextStyle(color: Colors.red.withValues(alpha: 0.8), fontSize: 12.sp)),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: sentence.asMap().entries.map((e) {
              final i = e.key;
              final word = e.value;
              return GestureDetector(
                onLongPress: () => _notifier.removeFromSentence(i),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: purple.withValues(alpha: 0.3)),
                  ),
                  child: Text(word.label,
                      style: TextStyle(color: purple, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 6.h),
          Text(S.get('long_press_remove'),
              style: TextStyle(color: subColor, fontSize: 10.sp)),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    final isResult = _notifier.isSuccess || _notifier.isError;
    const purple = Color(0xFF7C3AED);

    return Column(
      children: [
        // Add Sign button — always visible after first result
        if (isResult)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: GestureDetector(
              onTap: () {
                _videoController?.dispose();
                _videoController = null;
                setState(() => _videoReady = false);
                _notifier.reset();
                _showSourcePicker();
              },
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: const LinearGradient(colors: [purple, Color(0xFF9C8FFF)]),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(S.get('add_sign'),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),

        // Upload first video button (idle/error state)
        if (!isResult)
          GestureDetector(
            onTap: _showSourcePicker,
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(colors: [purple, Color(0xFF9C8FFF)]),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_rounded, color: Colors.white, size: 22.sp),
                  SizedBox(width: 8.w),
                  Text(S.get('upload_your_video'),
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
