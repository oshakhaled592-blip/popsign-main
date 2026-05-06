import 'package:flutter/material.dart';
import '../../../../core/theme/styles.dart';

class LanguageSelectedList extends StatefulWidget {
  final List<String> languages;

  const LanguageSelectedList({super.key, required this.languages});

  @override
  State<LanguageSelectedList> createState() =>
      _LanguageSelectedListState();
}

class _LanguageSelectedListState
    extends State<LanguageSelectedList> {
  String selected = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.languages.map((lang) {
        final isSelected = selected == lang;

        return GestureDetector(
          onTap: () {
            setState(() {
              selected = lang;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lang,
                    style: AppTextStyles.body(context),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check,
                      color:
                          Theme.of(context).colorScheme.onPrimary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}