import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/language_notifier.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    languageNotifier.addListener(_rebuild);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await AuthService().getEmail();
    if (mounted) {
      setState(() {
        _name  = prefs.getString('userName') ?? '';
        _email = email ?? '';
      });
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _editName(BuildContext context, bool isDark, Color textColor, Color subText) {
    final controller = TextEditingController(text: _name);
    const accent = Color(0xFF22C55E);
    final cardColor = isDark ? const Color(0xFF171C2B) : Colors.white;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          S.get('full_name'),
          style: TextStyle(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textColor, fontSize: 15.sp),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: S.get('full_name'),
            hintStyle: TextStyle(color: subText, fontSize: 14.sp),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.get('cancel'), style: TextStyle(color: subText, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              final nav = Navigator.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', newName);
              if (!mounted) return;
              setState(() => _name = newName);
              nav.pop();
            },
            child: Text(S.get('save'), style: TextStyle(color: accent, fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgColor    = isDark ? const Color(0xFF0B1020) : const Color(0xFFF5F7FB);
    final cardColor  = isDark ? const Color(0xFF171C2B) : Colors.white;
    final textColor  = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subText    = isDark ? Colors.white54 : const Color(0xFF9CA3AF);
    const accent     = Color(0xFF22C55E);

    final cardShadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 46.w,
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: cardShadow,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18.sp),
                ),
              ),

              SizedBox(height: 28.h),

              ValueListenableBuilder<LanguageInfo>(
                valueListenable: languageNotifier,
                builder: (context, value, child) => Text(
                  S.get('account'),
                  style: TextStyle(color: textColor, fontSize: 24.sp, fontWeight: FontWeight.w700),
                ),
              ),

              SizedBox(height: 28.h),

              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52.r,
                      backgroundImage: const AssetImage("assets/images/profile.png"),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 22.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: bgColor, width: 2),
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: ValueListenableBuilder<LanguageInfo>(
                    valueListenable: languageNotifier,
                    builder: (context, value, child) => Text(
                      S.get('verified'),
                      style: TextStyle(color: accent, fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: cardShadow,
                  border: isDark
                      ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                      : Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    _infoTile(
                      icon: Icons.person_outline_rounded,
                      label: S.get('full_name'),
                      value: _name.isNotEmpty ? _name : '—',
                      textColor: textColor,
                      subText: subText,
                      accent: accent,
                      isDark: isDark,
                      hasDivider: true,
                      onEdit: () => _editName(context, isDark, textColor, subText),
                    ),
                    _infoTile(
                      icon: Icons.email_outlined,
                      label: S.get('email'),
                      value: _email.isNotEmpty ? _email : '—',
                      textColor: textColor,
                      subText: subText,
                      accent: accent,
                      isDark: isDark,
                      hasDivider: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subText,
    required Color accent,
    required bool isDark,
    required bool hasDivider,
    VoidCallback? onEdit,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: isDark ? Colors.white70 : accent, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: subText, fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      value,
                      style: TextStyle(color: textColor, fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.edit_outlined, color: isDark ? Colors.white54 : accent, size: 16.sp),
                  ),
                ),
            ],
          ),
        ),
        if (hasDivider)
          Divider(
            height: 1,
            indent: 68.w,
            endIndent: 0,
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.grey.shade200,
          ),
      ],
    );
  }
}
