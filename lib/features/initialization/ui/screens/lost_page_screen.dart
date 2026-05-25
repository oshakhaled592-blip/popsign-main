import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popsign/core/routing/routes.dart';

import '../../../../core/models/prediction_model.dart';
import '../../../../core/state/translation_notifier.dart';

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
    _notifier.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notifier.removeListener(_rebuild);
    _notifier.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final status = await _requestVideoPermission();
    if (!status) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to pick a video'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    await _notifier.predict(File(picked.path));
  }

  Future<bool> _requestVideoPermission() async {
    if (await Permission.videos.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    final videos = await Permission.videos.request();
    if (videos.isGranted) return true;

    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? const Color(0xFF0B0F18) : const Color(0xFFF2F4FA);
    final cardBg    = isDark ? const Color(0xFF141A29) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor  = isDark ? Colors.white38 : Colors.grey.shade500;
    final btnBg     = isDark ? const Color(0xFF1E2538) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildHeader(textColor, btnBg),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: switch (_notifier.status) {
                  TranslationStatus.idle    => _buildIdle(textColor, subColor),
                  TranslationStatus.loading => _buildLoading(textColor, subColor),
                  TranslationStatus.success => _buildResult(cardBg, textColor, subColor, isDark),
                  TranslationStatus.error   => _buildError(textColor, subColor),
                },
              ),
              const Spacer(),
              if (!_notifier.isLoading) _buildActionButton(),
              SizedBox(height: 12.h),
              Container(
                width: 120.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color btnBg) {
    return Row(
      children: [
        _iconBtn(Icons.arrow_back_ios_new_rounded, btnBg, textColor,
            () => Navigator.pop(context)),
        Expanded(
          child: Text(
            'Translate',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        _iconBtn(Icons.menu_rounded, btnBg, textColor,
            () => Navigator.pushNamed(context, Routes.profile)),
      ],
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
              color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.video_camera_back_rounded, size: 52.sp, color: const Color(0xFF6C63FF)),
          ),
        ),
        SizedBox(height: 24.h),
        Text('Upload your video',
            style: TextStyle(color: textColor, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        Text(
          'Record or choose a sign-language\nvideo to get the translation',
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 14.sp, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLoading(Color textColor, Color subColor) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64.w,
          height: 64.w,
          child: const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6C63FF)),
        ),
        SizedBox(height: 28.h),
        Text('Analyzing video…',
            style: TextStyle(color: textColor, fontSize: 20.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 10.h),
        Text(
          'The model is processing\nyour sign language',
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 14.sp, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildResult(Color cardBg, Color textColor, Color subColor, bool isDark) {
    final result = _notifier.result!;
    final top    = result.top;
    const purple = Color(0xFF6C63FF);

    return Column(
      key: const ValueKey('result'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
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
                child: Text('Translation',
                    style: TextStyle(color: purple, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 16.h),
              Text(
                top.label,
                style: TextStyle(color: textColor, fontSize: 36.sp, fontWeight: FontWeight.bold),
              ),
              if (top.labelAr.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  top.labelAr,
                  style: TextStyle(color: subColor, fontSize: 22.sp, fontWeight: FontWeight.w500),
                ),
              ],
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Confidence  ${top.percent}',
                  style: TextStyle(color: Colors.green, fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        if (result.predictions.length > 1) ...[
          SizedBox(height: 20.h),
          Text('Other possibilities', style: TextStyle(color: subColor, fontSize: 13.sp)),
          SizedBox(height: 10.h),
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
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 40.sp),
        ),
        SizedBox(height: 20.h),
        Text('Something went wrong',
            style: TextStyle(color: textColor, fontSize: 18.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Text(
          _notifier.error,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: subColor, fontSize: 13.sp, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final isResult = _notifier.isSuccess || _notifier.isError;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        key: ValueKey(isResult),
        onTap: isResult ? _notifier.reset : _pickVideo,
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)]),
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
              Icon(
                isResult ? Icons.video_call_rounded : Icons.upload_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                isResult ? 'Upload new video' : 'Upload your video',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
