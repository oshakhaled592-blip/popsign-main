import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          String level = data["level"] ?? "A1";
          int words = data["learnedWords"] ?? 0;

          // كل level نفترضه 500 كلمة
          double progress = (words / 500) * 100;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Welcome 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // LEVEL CARD
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text("Current Level"),
                    subtitle: Text(level),
                  ),
                ),

                const SizedBox(height: 15),

                // WORDS CARD
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text("Learned Words"),
                    subtitle: Text("$words words"),
                  ),
                ),

                const SizedBox(height: 15),

                // PROGRESS CARD
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text("Progress"),
                    subtitle: Text("${progress.toStringAsFixed(1)}%"),
                  ),
                ),

                const SizedBox(height: 30),

                // BUTTON TO LEVELS
                ElevatedButton(
                  onPressed: () {
                    // هنا تفتحي LevelsScreen
                  },
                  child: const Text("Go to Levels"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}