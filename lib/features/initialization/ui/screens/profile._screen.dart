import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDark = true;

  @override
  void initState() {
    super.initState();
    loadTheme(); // 👈 تحميل الثيم
  }

  /// 📥 LOAD THEME
  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? true;
    });
  }

  /// 💾 SAVE THEME
  void saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F7FA);
    Color cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    Color subText = isDark ? Colors.white38 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔙 BUTTON
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_rounded,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 👤 PROFILE
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Mrh Raju",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.verified,
                              color: Colors.green, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Verified Profile",
                        style: TextStyle(color: subText),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFEAEFF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "3 Orders",
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// 🌗 DARK MODE
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: textColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isDark ? "Dark Mode" : "Light Mode",
                      style: TextStyle(color: textColor),
                    ),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          isDark = value;
                        });
                        saveTheme(value); // 💾 حفظ
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// 🔴 LOGOUT
              Row(
                children: const [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}