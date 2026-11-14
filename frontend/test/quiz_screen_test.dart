import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notes/domain/entities/lesson_summary.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:frontend/features/notes/domain/entities/quiz_submission_result.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';
import 'package:frontend/features/notes/presentation/screens/quiz_screen.dart';
import 'package:frontend/features/notes/presentation/viewmodels/notes_view_model.dart';
import 'package:frontend/features/notes/domain/usecases/generate_quiz.dart';
import 'package:frontend/features/notes/domain/usecases/summarize_lesson.dart';
import 'package:frontend/features/notes/domain/usecases/submit_quiz.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('submits selected answers and displays server grading', (
    tester,
  ) async {
    const quiz = Quiz(
      quizId: 'quiz-1',
      title: 'Programlama',
      totalQuestions: 1,
      questions: [
        QuizQuestion(
          id: 1,
          question: 'Listeler nasıl indekslenir?',
          options: ['Sıfırdan', 'Birden', 'Rastgele', 'İndeks yoktur'],
        ),
      ],
    );
    final repository = _FakeNotesRepository();
    final viewModel = NotesViewModel(
      SummarizeLesson(repository),
      GenerateQuiz(repository),
      SubmitQuiz(repository),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const MaterialApp(home: QuizScreen(quiz: quiz)),
      ),
    );

    final completeButton = find.text('Yanıtlanan: 0/1');
    expect(completeButton, findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: completeButton,
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Sıfırdan'));
    await tester.pump();
    expect(find.text('Testi Tamamla'), findsOneWidget);

    await tester.tap(find.text('Testi Tamamla'));
    await tester.pumpAndSettle();
    expect(repository.submittedQuizId, 'quiz-1');
    expect(repository.submittedAnswers, {1: 'Sıfırdan'});
    expect(find.text('Test Sonucu'), findsOneWidget);
    expect(find.text('Başarı oranı: 100%'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Doğru cevap: Sıfırdan',
      ),
      findsOneWidget,
    );
    expect(find.text('İndeksler sıfırdan başlar.'), findsOneWidget);

    await tester.tap(find.text('Kapat'));
    await tester.pumpAndSettle();
    expect(find.text('Sonuçları Gör'), findsOneWidget);
  });
}

class _FakeNotesRepository implements NotesRepository {
  String? submittedQuizId;
  Map<int, String>? submittedAnswers;

  @override
  Future<QuizSubmissionResult> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
  }) async {
    submittedQuizId = quizId;
    submittedAnswers = Map.of(answers);
    return const QuizSubmissionResult(
      quizId: 'quiz-1',
      totalQuestions: 1,
      correctCount: 1,
      scorePercent: 100,
      results: [
        QuizQuestionResult(
          questionId: 1,
          question: 'Listeler nasıl indekslenir?',
          selectedAnswer: 'Sıfırdan',
          correctAnswer: 'Sıfırdan',
          isCorrect: true,
          explanation: 'İndeksler sıfırdan başlar.',
        ),
      ],
    );
  }

  @override
  Future<Quiz> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LessonSummary> summarizeLesson({
    required String title,
    required String text,
  }) {
    throw UnimplementedError();
  }
}
