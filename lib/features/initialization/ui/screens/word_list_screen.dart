import 'package:flutter/material.dart';
import 'package:popsign/core/routing/routes.dart';
import 'learn_new_words_screen.dart';

/// ================= MODEL =================
class WordModel {
  String word;
  int progress;
  String image;

  WordModel(this.word, this.progress, this.image);

  bool get isDone => progress == 3;
}

/// ================= SCREEN =================
class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

enum ResetState { active, loading }

class _WordListScreenState extends State<WordListScreen> {
  ResetState resetState = ResetState.active;

  List<WordModel> words = [
    WordModel("mother", 0, "assets/images/mother.png"),
    WordModel("day", 3, "assets/images/day.png"),
    WordModel("you", 2, "assets/images/you.png"),
    WordModel("get", 1, "assets/images/get.png"),
    WordModel("put", 3, "assets/images/put.png"),
    WordModel("race", 3, "assets/images/race.png"),
    WordModel("start", 1, "assets/images/start.png"),
    WordModel("finish", 3, "assets/images/finish.png"),
  ];

  /// 🔢 المتبقي
  int get remaining =>
      words.where((w) => w.progress < 3).length;

  /// 📊 النسبة
  int get percent {
    int total = words.length * 3;
    int done =
        words.fold(0, (sum, w) => sum + w.progress);
    return ((done / total) * 100).toInt();
  }

  /// 🔥 فتح التعلم
  void onLearn(int index) async {
    /// ✔ يزود التقدم
    setState(() {
      if (words[index].progress < 3) {
        words[index].progress++;
      }
    });

    /// ✔ يفتح الشاشة الجديدة (بدون word/image)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LearnNewWordsScreen(),
      ),
    );
  }

  /// 🔴 Reset
  void onReset() async {
    setState(() => resetState = ResetState.loading);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      for (var w in words) {
        w.progress = 0;
      }
      resetState = ResetState.active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      /// 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1218),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, Routes.profile);
          },
        ),
        title: const Text(
          "A1 Level",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.close, color: Colors.white),
          )
        ],
      ),

      /// 📱 BODY
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// 🔴 RESET
          ResetButton(
            state: resetState,
            onTap: onReset,
          ),

          const SizedBox(height: 10),

          /// 📊 TEXT
          Text(
            "$remaining new words left • $percent% complete",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          /// 📋 LIST
          Expanded(
            child: ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final item = words[index];

                return WordCard(
                  word: item.word,
                  image: item.image,
                  progress: item.progress,
                  isDone: item.isDone,
                  onTap: () => onLearn(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= RESET BUTTON =================
class ResetButton extends StatelessWidget {
  final ResetState state;
  final VoidCallback onTap;

  const ResetButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == ResetState.loading ? null : onTap,
      child: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151922),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red),
        ),
        child: Center(
          child: state == ResetState.loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Reset all progress",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

/// ================= WORD CARD =================
class WordCard extends StatelessWidget {
  final String word;
  final String image;
  final int progress;
  final bool isDone;
  final VoidCallback onTap;

  const WordCard({
    super.key,
    required this.word,
    required this.image,
    required this.progress,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          /// 🖼️ IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image, color: Colors.white30),
            ),
          ),

          const SizedBox(width: 12),

          /// WORD
          Expanded(
            child: Text(
              word,
              style: TextStyle(
                color: isDone ? Colors.white38 : Colors.white,
                fontSize: 16,
              ),
            ),
          ),

          /// DOTS
          Row(
            children: List.generate(3, (i) {
              bool active = i < progress;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.green
                      : const Color(0xFF2A2F3A),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          const SizedBox(width: 10),

          /// CHECK
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green
                  : const Color(0xFF2A2F3A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color:
                  isDone ? Colors.white : Colors.white30,
            ),
          ),

          const SizedBox(width: 10),

          /// 🔘 BUTTON
          GestureDetector(
            onTap: isDone ? null : onTap,
            child: Container(
              height: 36,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF2A2F3A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Learn",
                  style: TextStyle(
                    color: isDone
                        ? Colors.white38
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}