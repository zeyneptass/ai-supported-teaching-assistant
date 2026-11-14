import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_submission_result.dart';
import 'notes_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.result,
  });

  final Quiz quiz;
  final QuizSubmissionResult result;

  int get _incorrectCount =>
      (result.totalQuestions - result.correctCount)
          .clamp(0, result.totalQuestions)
          .toInt();

  String _formatScore(double score) {
    final rounded = score.roundToDouble();
    return score == rounded
        ? rounded.toStringAsFixed(0)
        : score.toStringAsFixed(1);
  }

  void _backToNotes(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == NotesScreen.routeName || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonuçları ve Çözüm Analizi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                _buildSummaryCard(context),
                const SizedBox(height: 22),
                Text(
                  'Soru bazlı çözüm',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...result.results.map(
                  (questionResult) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _QuestionAnalysisCard(
                      result: questionResult,
                      fallbackQuestion: _findQuestion(questionResult.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _backToNotes(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Ders Notlarına Dön'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  QuizQuestion? _findQuestion(int id) {
    for (final question in quiz.questions) {
      if (question.id == id) return question;
    }
    return null;
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quiz.title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '%${_formatScore(result.scorePercent)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Başarı yüzdesi',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryBadge(
                label: 'Doğru',
                value: '${result.correctCount}',
                color: const Color(0xFFDCFCE7),
                foreground: const Color(0xFF166534),
              ),
              _SummaryBadge(
                label: 'Yanlış',
                value: '$_incorrectCount',
                color: const Color(0xFFFEE2E2),
                foreground: const Color(0xFF991B1B),
              ),
              _SummaryBadge(
                label: 'Toplam soru',
                value: '${result.totalQuestions}',
                color: Colors.white.withValues(alpha: 0.16),
                foreground: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionAnalysisCard extends StatelessWidget {
  const _QuestionAnalysisCard({
    required this.result,
    required this.fallbackQuestion,
  });

  final QuestionResult result;
  final QuizQuestion? fallbackQuestion;

  @override
  Widget build(BuildContext context) {
    final options = result.options.isNotEmpty
        ? result.options
        : fallbackQuestion?.options ?? const <String>[];
    final visibleOptions = options.toSet().toList();
    for (final answer in [result.selectedAnswer, result.correctAnswer]) {
      if (answer.isNotEmpty && !visibleOptions.contains(answer)) {
        visibleOptions.add(answer);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  result.question.isEmpty
                      ? fallbackQuestion?.question ?? 'Soru ${result.id}'
                      : result.question,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.4),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(isCorrect: result.isCorrect),
            ],
          ),
          const SizedBox(height: 14),
          if (visibleOptions.isNotEmpty)
            ...visibleOptions.map((option) {
              final isSelected = option == result.selectedAnswer;
              final isCorrectAnswer = result.correctAnswer.isNotEmpty &&
                  option == result.correctAnswer;
              final highlightCorrect = isCorrectAnswer &&
                  (!result.isCorrect || !isSelected);
              final isWrongSelection = isSelected && !result.isCorrect;
              final highlighted = (isSelected && result.isCorrect) ||
                  highlightCorrect ||
                  isWrongSelection;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OptionReview(
                  text: option,
                  selected: isSelected,
                  correctAnswer: isCorrectAnswer,
                  correctSelection: isSelected && result.isCorrect,
                  wrongSelection: isWrongSelection,
                  highlighted: highlighted,
                ),
              );
            })
          else
            _answerOnlyReview(result),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              border: Border.all(color: const Color(0xFFBAE6FD)),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF0284C7),
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    result.explanation.isEmpty
                        ? 'Doğru cevap: ${result.correctAnswer.isEmpty ? "Sunucuda belirtilmedi" : result.correctAnswer}'
                        : result.explanation,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerOnlyReview(QuestionResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OptionReview(
          text: result.selectedAnswer.isEmpty
              ? 'Yanıt verilmedi'
              : result.selectedAnswer,
          selected: true,
          correctAnswer: result.correctAnswer == result.selectedAnswer &&
              result.correctAnswer.isNotEmpty,
          correctSelection: result.isCorrect,
          wrongSelection: !result.isCorrect,
          highlighted: true,
        ),
        if (!result.isCorrect && result.correctAnswer.isNotEmpty) ...[
          const SizedBox(height: 8),
          _OptionReview(
            text: result.correctAnswer,
            selected: false,
            correctAnswer: true,
            correctSelection: false,
            wrongSelection: false,
            highlighted: true,
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCorrect ? 'Doğru' : 'Yanlış',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _OptionReview extends StatelessWidget {
  const _OptionReview({
    required this.text,
    required this.selected,
    required this.correctAnswer,
    required this.correctSelection,
    required this.wrongSelection,
    required this.highlighted,
  });

  final String text;
  final bool selected;
  final bool correctAnswer;
  final bool correctSelection;
  final bool wrongSelection;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isGreen = correctSelection || (correctAnswer && !wrongSelection);
    final background = isGreen
        ? const Color(0xFFF0FDF4)
        : wrongSelection
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF8FAFC);
    final border = isGreen
        ? const Color(0xFF86EFAC)
        : wrongSelection
        ? const Color(0xFFFCA5A5)
        : AppTheme.border;
    final iconColor = isGreen
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            highlighted
                ? (isGreen ? Icons.check_circle_rounded : Icons.cancel_rounded)
                : Icons.radio_button_unchecked_rounded,
            size: 19,
            color: highlighted ? iconColor : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: highlighted
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF475569),
                    fontWeight:
                        highlighted ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (selected || (correctAnswer && !correctSelection)) ...[
                  const SizedBox(height: 3),
                  Text(
                    selected && correctSelection
                        ? 'Sizin cevabınız • Doğru cevap'
                        : selected
                        ? 'Sizin cevabınız'
                        : 'Doğru cevap',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isGreen
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
