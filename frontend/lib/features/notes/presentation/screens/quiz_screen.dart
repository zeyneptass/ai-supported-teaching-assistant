import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/quiz.dart';
import '../viewmodels/notes_view_model.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotesViewModel>().beginQuiz(widget.quiz);
    });
  }

  bool _isComplete(NotesViewModel viewModel) =>
      widget.quiz.questions.isNotEmpty &&
      widget.quiz.questions.every(
        (question) => viewModel.quizAnswers.containsKey(question.id),
      );

  Future<void> _completeQuiz(NotesViewModel viewModel) async {
    if (!_isComplete(viewModel) || viewModel.isLoading) return;
    final result = await viewModel.submitQuiz(
      quizId: widget.quiz.quizId,
      quiz: widget.quiz,
    );
    if (!mounted || result == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizResultScreen(quiz: widget.quiz, result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotesViewModel>();
    final answers = viewModel.quizAnswers;
    final answeredCount = widget.quiz.questions
        .where((question) => answers.containsKey(question.id))
        .length;
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: _buildProgress(context, answeredCount),
          ),
          Expanded(
            child: widget.quiz.questions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_outlined, size: 44),
                          SizedBox(height: 12),
                          Text(
                            'Bu testte henüz soru yok.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                    children: [
                      for (
                        var index = 0;
                        index < widget.quiz.questions.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildQuestionCard(context, viewModel, index),
                        ),
                    ],
                  ),
          ),
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isComplete(viewModel) && !viewModel.isLoading
                          ? () => _completeQuiz(viewModel)
                          : null,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          if (viewModel.isSubmitting)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.statusMessage ??
                        'Cevaplarınız değerlendiriliyor...',
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
                  onPressed: _isComplete(viewModel) && !viewModel.isLoading
                      ? () => _completeQuiz(viewModel)
                      : null,
                  icon: viewModel.isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Testi Tamamla ve Değerlendir'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context, int answeredCount) {
    final total = widget.quiz.questions.length;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Test ilerlemesi',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '$answeredCount / $total',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Test kodu: ${widget.quiz.quizId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: total == 0 ? 0 : answeredCount / total,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    NotesViewModel viewModel,
    int index,
  ) {
    final colors = Theme.of(context).colorScheme;
    final question = widget.quiz.questions[index];
    final selected = viewModel.quizAnswers[question.id];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${index + 1} / ${widget.quiz.questions.length}',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          ...question.options.map((option) {
            final isSelected = selected == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                button: true,
                selected: isSelected,
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: viewModel.isLoading
                      ? null
                      : () => viewModel.selectQuizAnswer(
                          quiz: widget.quiz,
                          questionId: question.id,
                          answer: option,
                        ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primaryContainer
                          : colors.surfaceContainerLow,
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.outlineVariant,
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
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected
                                  ? colors.onPrimaryContainer
                                  : colors.onSurface,
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
              ),
            );
          }),
        ],
      ),
    );
  }
}
