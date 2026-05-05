import 'package:flutter/material.dart';
import '../../../../core/theme/styles.dart';
import '../../../../core/widgets/linear_button.dart';

class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<SelectCategoriesScreen> createState() =>
      _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState
    extends State<SelectCategoriesScreen> {
  final List<String> categories = [
    "Family",
    "Food",
    "Travel",
    "Work",
  ];

  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Select Categories", style: AppTextStyles.title(context)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              children: categories.map((cat) {
                final isSelected = selected.contains(cat);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selected.remove(cat);
                      } else {
                        selected.add(cat);
                      }
                    });
                  },
                  child: Chip(
                    label: Text(cat),
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            LinearButton(
              text: "Continue",
              onPressed: () {
                Navigator.pushNamed(context, "/wordList");
              },
            ),
          ],
        ),
      ),
    );
  }
}