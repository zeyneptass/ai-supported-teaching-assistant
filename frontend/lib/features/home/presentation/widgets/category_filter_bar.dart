import 'package:flutter/material.dart';

enum SavedLessonFilter { all, summarized, quizSolved }

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SavedLessonFilter selected;
  final ValueChanged<SavedLessonFilter> onSelected;

  static const _filters = [
    (SavedLessonFilter.all, 'Tümü'),
    (SavedLessonFilter.summarized, 'Özetlenenler'),
    (SavedLessonFilter.quizSolved, 'Testi Çözülenler'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = _filters[index];
          return ChoiceChip(
            label: Text(label),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}
