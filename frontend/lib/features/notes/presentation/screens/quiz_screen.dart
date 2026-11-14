import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_submission_result.dart';
import '../viewmodels/notes_view_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> _answers = {};
  QuizSubmissionResult? _submissionResult;

  bool get _isComplete => widget.quiz.questions.every(
    (question) => _answers.containsKey(question.id),
  );

  Future<void> _completeQuiz(NotesViewModel viewModel) async {
    if (!_isComplete || viewModel.isLoading) return;
    if (_submissionResult case final result?) {
      await _showResults(result);
      return;
    }

    final result = await viewModel.submitQuiz(
      quizId: widget.quiz.quizId,
      answers: _answers,
    );
    if (!mounted || result == null) return;
    setState(() => _submissionResult = result);
    await _showResults(result);
  }

  Future<void> _showResults(QuizSubmissionResult result) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.verified_rounded,
          color: AppTheme.primary,
          size: 34,
        ),
        title: const Text('Test Sonucu'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${result.correctCount} / ${result.totalQuestions} doğru',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Başarı oranı: ${_formatScore(result.scorePercent)}%',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                ...result.results.map(
                  (questionResult) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: questionResult.isCorrect
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFEF2F2),
                        border: Border.all(
                          color: questionResult.isCorrect
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFECACA),
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                questionResult.isCorrect
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 19,
                                color: questionResult.isCorrect
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  questionResult.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _answerLine(
                            'Cevabınız',
                            questionResult.selectedAnswer,
                          ),
                          _answerLine(
                            'Doğru cevap',
                            questionResult.correctAnswer,
                          ),
                          if (questionResult.explanation.trim().isNotEmpty) ...[
                            const SizedBox(height: 7),
                            Text(
                              questionResult.explanation,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _formatScore(double score) {
    return score == score.roundToDouble()
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);
  }

  Widget _answerLine(String label, String answer) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: answer),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              widget.quiz.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              itemCount: widget.quiz.questions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                final selected = _answers[question.id];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.035),
                        blurRadius: 12,
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
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                question.question,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...question.options.map((option) {
                        final isSelected = selected == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap:
                                viewModel.isLoading || _submissionResult != null
                                ? null
                                : () => setState(() {
                                    _answers[question.id] = option;
                                  }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withValues(alpha: 0.06)
                                    : const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    size: 20,
                                    color: isSelected
                                        ? AppTheme.primary
                                        : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : const Color(0xFF334155),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (viewModel.isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.statusMessage ?? 'Cevaplar kontrol ediliyor...',
                    style: Theme.of(context).textTheme.bodySmall,
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
                  onPressed: _isComplete && !viewModel.isLoading
                      ? () => _completeQuiz(viewModel)
                      : null,
                  icon: Icon(
                    _submissionResult == null
                        ? Icons.check_rounded
                        : Icons.assessment_outlined,
                  ),
                  label: Text(
                    _submissionResult != null
                        ? 'Sonuçları Gör'
                        : _isComplete
                        ? 'Testi Tamamla'
                        : 'Yanıtlanan: ${_answers.length}/${widget.quiz.questions.length}',
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
