import 'package:flutter/material.dart';

import '../../../notes/domain/entities/saved_lesson.dart';

class SavedLessonCard extends StatelessWidget {
  const SavedLessonCard({super.key, required this.lesson, required this.onTap});

  final SavedLesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final result = lesson.latestResult;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      lesson.latestQuiz == null
                          ? Icons.menu_book_rounded
                          : Icons.quiz_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (result != null) ...[
                    const SizedBox(width: 8),
                    _ScoreBadge(score: result.scorePercent),
                  ],
                ],
              ),
              const SizedBox(height: 11),
              Text(
                lesson.summary.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    lesson.latestQuiz == null
                        ? Icons.auto_awesome_outlined
                        : lesson.latestResult == null
                        ? Icons.pending_outlined
                        : Icons.task_alt_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _activityLabel(lesson),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _activityLabel(SavedLesson lesson) {
    final quiz = lesson.latestQuiz;
    if (quiz == null) return 'Özet hazır · ${lesson.updatedAtLabel}';
    if (lesson.latestResult == null) return '${quiz.title} · Çözülmedi';
    return '${quiz.title} · Test çözüldü';
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? const Color(0xFF15803D)
        : Theme.of(context).colorScheme.error;
    final background = score >= 70
        ? const Color(0xFFDCFCE7)
        : Theme.of(context).colorScheme.errorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '%${score.round()}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

extension on SavedLesson {
  String get updatedAtLabel {
    final date = updatedAt;
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }
}
