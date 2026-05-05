import 'package:flutter/material.dart';

class IHeartYouApp extends StatefulWidget {
  const IHeartYouApp({super.key});

  @override
  State<IHeartYouApp> createState() => _IHeartYouAppState();
}

class _IHeartYouAppState extends State<IHeartYouApp> {
  bool isDark = true;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🌙 DARK
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF22C55E),
        ),
      ),

      /// 🌑 LIGHT
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1218),
        cardColor: const Color(0xFF151922),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E),
        ),
      ),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Demo"),
              actions: [
                IconButton(
                  icon: Icon(
                    isDark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  onPressed: toggleTheme,
                )
              ],
            ),
            body: const Center(
              child: Text("App Running"),
            ),
          );
        },
      ),
    );
  }
}