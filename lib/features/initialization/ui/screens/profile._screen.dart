import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/theme/theme_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool isDark;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    isDark = themeNotifier.value == ThemeMode.dark;
    languageNotifier.addListener(_rebuild);
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userName = prefs.getString('userName') ?? 'User');
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title — coming soon"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor    = isDark ? const Color(0xFF0B1020) : const Color(0xFFF5F7FB);
    final cardColor  = isDark ? const Color(0xFF171C2B) : Colors.white;
    final textColor  = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subText    = isDark ? Colors.white54 : const Color(0xFF9CA3AF);

    final cardShadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ];

    const accent = Color(0xFF22C55E);

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
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textColor,
                    size: 18.sp,
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: cardShadow,
                  border: isDark
                      ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                      : Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 34.r,
                          backgroundImage:
                              const AssetImage("assets/images/profile.png"),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 18.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2),
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 10.sp),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            S.get('verified'),
                            style: TextStyle(color: subText, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ValueListenableBuilder<LanguageInfo>(
                        valueListenable: languageNotifier,
                        builder: (_, __, ___) => Text(
                          S.get('my_progress'),
                          style: TextStyle(
                            color: accent,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              Text(
                S.get('settings'),
                style: TextStyle(
                  color: subText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 12.h),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  children: [
                    profileTile(
                      icon: Icons.dark_mode_outlined,
                      title: S.get('dark_mode'),
                      textColor: textColor,
                      subText: subText,
                      isDivider: true,
                      trailing: Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: isDark,
                          activeThumbColor: Colors.white,
                          activeTrackColor: accent,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (value) {
                            setState(() => isDark = value);
                            saveTheme(value);
                            themeNotifier.value =
                                value ? ThemeMode.dark : ThemeMode.light;
                          },
                        ),
                      ),
                    ),

                    profileTile(
                      icon: Icons.person_outline_rounded,
                      title: S.get('account'),
                      textColor: textColor,
                      subText: subText,
                      isDivider: true,
                      onTap: () => Navigator.pushNamed(context, Routes.accountInfo),
                    ),

                    profileTile(
                      icon: Icons.lock_outline_rounded,
                      title: S.get('password'),
                      textColor: textColor,
                      subText: subText,
                      isDivider: true,
                      onTap: () => _showComingSoon(S.get('password')),
                    ),

                    profileTile(
                      icon: Icons.language_rounded,
                      title: S.get('translate'),
                      textColor: textColor,
                      subText: subText,
                      isDivider: true,
                      onTap: () => Navigator.pushNamed(context, Routes.lostPage),
                    ),

                    profileTile(
                      icon: Icons.bar_chart_rounded,
                      title: S.get('my_progress'),
                      textColor: textColor,
                      subText: subText,
                      isDivider: false,
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.wordList),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              GestureDetector(
                onTap: () async {
                  final nav = Navigator.of(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 10.w),
                      Text(
                        S.get('logout'),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color subText,
    required bool isDivider,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFF22C55E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? Colors.white70 : const Color(0xFF22C55E),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
                if (trailing == null)
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: subText, size: 14),
              ],
            ),
          ),
          if (isDivider)
            Divider(
              height: 1,
              indent: 68.w,
              endIndent: 0,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.grey.shade200,
            ),
        ],
      ),
    );
  }
}
