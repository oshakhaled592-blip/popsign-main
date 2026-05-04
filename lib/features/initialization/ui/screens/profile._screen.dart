import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    Color cardColor =
        isDark ? const Color(0xFF161B22) : Colors.grey.shade100;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color subText = Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔹 TOP BAR
              Row(
                children: [
                  /// ☰ MENU ICON
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha:0.05)
                          : Colors.black.withValues(alpha:0.05),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.drag_handle_rounded, // الثلاث شرط
                        color: textColor,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 PROFILE
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
                          ? Colors.white.withValues(alpha:0.1)
                          : Colors.grey.shade300,
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

              /// 🔹 DARK MODE
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, color: textColor),
                    const SizedBox(width: 10),
                    Text(
                      isDark ? "Dark Mode" : "Light Mode",
                      style: TextStyle(color: textColor),
                    ),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      onChanged: (value) {
                        setState(() {
                          isDark = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 ITEMS
              buildItem(Icons.info_outline, "Account Information", textColor, cardColor),
              buildItem(Icons.lock_outline, "Password", textColor, cardColor),
              buildItem(Icons.translate, "Translate", textColor, cardColor),
              buildItem(Icons.bar_chart, "My progress", textColor, cardColor),

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

  Widget buildItem(
      IconData icon, String text, Color textColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}