import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popsign/core/helpers/level_helper.dart';


class LevelsScreen extends StatelessWidget {
  final String uid;

  const LevelsScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return const Center(child: Text("No user data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          String userLevel = data["level"];

          List<String> levels = ["A1", "A2", "B1", "B2", "C1"];

          return ListView.builder(
            itemCount: levels.length,
            itemBuilder: (context, index) {
              String level = levels[index];

              bool unlocked = isUnlocked(level, userLevel);

              return ListTile(
                title: Text(level),
                trailing: Icon(
                  unlocked ? Icons.lock_open : Icons.lock,
                  color: unlocked ? Colors.green : Colors.red,
                ),
                onTap: unlocked
                    ? () {
                        print("Open $level");
                        // هنا تفتحي محتوى المستوى
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}