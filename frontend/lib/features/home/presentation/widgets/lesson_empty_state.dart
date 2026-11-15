import 'package:flutter/material.dart';

class LessonEmptyState extends StatelessWidget {
  const LessonEmptyState({super.key, required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.menu_book_outlined,
            size: 46,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            hasQuery ? 'Ders notu bulunamadı' : 'Henüz ders notun yok',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            hasQuery
                ? 'Başlığı kontrol edip tekrar aramayı dene.'
                : 'Yeni bir ders notu ekleyip özetini ve testini burada gör.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
