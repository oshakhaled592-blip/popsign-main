import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/language_notifier.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';

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
    String name = prefs.getString('userName') ?? '';
    if (name.isEmpty) {
      final email = await AuthService().getEmail() ?? '';
      name = email.isNotEmpty
          ? email.split('@').first.replaceAll('.', ' ').replaceAll('_', ' ')
          : '';
    }
    if (mounted) setState(() => _userName = name);
  }

  void _editName() {
    final controller = TextEditingController(text: _userName);
    final isDark = themeNotifier.value == ThemeMode.dark;
    const accent = AppColors.success;
    final subText = isDark ? Colors.white38 : AppColors.grayTextLight;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          S.get('full_name'),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 15.sp,
          ),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: S.get('full_name'),
            hintStyle: TextStyle(color: subText, fontSize: 14.sp),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accent, width: 2.w),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.get('cancel'),
                style: TextStyle(color: subText, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', name);
              if (!mounted) return;
              setState(() => _userName = name);
              nav.pop();
            },
            child: Text(S.get('save'),
                style: TextStyle(color: accent, fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bgColor    = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor  = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor  = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subText    = isDark ? Colors.white54 : AppColors.grayTextLight;

    final cardShadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ];

    const accent = AppColors.success;

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
                          backgroundColor: accent.withValues(alpha: 0.15),
                          child: _userName.isNotEmpty
                              ? Text(
                                  _userName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Icon(Icons.person_rounded, color: accent, size: 30.sp),
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
                              border: Border.all(color: cardColor, width: 2.w),
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 10.sp),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: GestureDetector(
                        onTap: _editName,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _userName.isNotEmpty ? _userName : S.get('tap_to_set_name'),
                                    style: TextStyle(
                                      color: _userName.isNotEmpty ? textColor : subText,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(Icons.edit_outlined, color: subText, size: 15.sp),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              S.get('verified'),
                              style: TextStyle(color: subText, fontSize: 13.sp),
                            ),
                          ],
                        ),
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
                        builder: (context, value, child) => Text(
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
                          inactiveTrackColor: isDark ? Colors.white24 : Colors.grey.shade300,
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
                      onTap: () => Navigator.pushNamed(context, Routes.accountInfo).then((_) => _loadName()),
                    ),

                    profileTile(
                      icon: Icons.lock_outline_rounded,
                      title: S.get('password'),
                      textColor: textColor,
                      subText: subText,
                      isDivider: true,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.get('coming_soon')),
                          backgroundColor: accent,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      ),
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
                      onTap: () => Navigator.pushNamed(context, Routes.levels),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              GestureDetector(
                onTap: () async {
                  final nav = Navigator.of(context);
                  await AuthService().logout();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('userName');
                  await prefs.remove('langCode');
                  await prefs.remove('langName');
                  await prefs.remove('langFlag');
                  await prefs.remove('userPriorKnowledge');
                  await prefs.remove('userPurpose');
                  await prefs.remove('userMinutesPerDay');
                  await prefs.remove('localEmail');
                  // hasSelectedLevel and userLevel are kept so the next login
                  // goes straight to dashboard without re-asking for a level.
                  nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error, size: 20.sp),
                      SizedBox(width: 10.w),
                      Text(
                        S.get('logout'),
                        style: TextStyle(
                          color: AppColors.error,
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
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? Colors.white70 : AppColors.success,
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
                trailing ??
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: subText, size: 14.sp),
              ],
            ),
          ),
          if (isDivider)
            Divider(
              height: 1.h,
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
