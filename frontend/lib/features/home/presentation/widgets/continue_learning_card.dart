import 'package:flutter/material.dart';

import '../../../notes/domain/entities/saved_lesson.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.lesson,
    required this.onContinue,
  });

  final SavedLesson lesson;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final result = lesson.latestResult;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: colors.onPrimaryContainer,
              ),
              SizedBox(width: 8),
              Text(
                'DEVAM ET',
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            lesson.latestQuiz == null
                ? 'Ders notuna kaldığın yerden devam et.'
                : result == null
                ? 'Testini tamamlayıp sonucunu gör.'
                : 'Son test skorun: %${_formatScore(result.scorePercent)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.onPrimaryContainer, height: 1.4),
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(
              lesson.latestQuiz == null
                  ? 'Notlara Git'
                  : result == null
                  ? 'Teste Devam Et'
                  : 'Testi Tekrar Çöz',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.surface,
              foregroundColor: colors.primary,
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(double score) {
    final rounded = score.roundToDouble();
    return score == rounded
        ? rounded.toStringAsFixed(0)
        : score.toStringAsFixed(1);
  }
}
