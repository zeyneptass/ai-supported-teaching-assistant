import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/exceptions.dart';
import 'package:frontend/features/notes/domain/entities/lesson_summary.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:frontend/features/notes/domain/entities/quiz_submission_result.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';
import 'package:frontend/features/notes/presentation/screens/quiz_screen.dart';
import 'package:frontend/features/notes/presentation/screens/quiz_result_screen.dart';
import 'package:frontend/features/notes/presentation/viewmodels/notes_view_model.dart';
import 'package:frontend/features/notes/domain/usecases/generate_quiz.dart';
import 'package:frontend/features/notes/domain/usecases/summarize_lesson.dart';
import 'package:frontend/features/notes/domain/usecases/submit_quiz.dart';
import 'package:provider/provider.dart';

const _quiz = Quiz(
  quizId: 'quiz-1',
  title: 'Programlama',
  totalQuestions: 2,
  questions: [
    QuizQuestion(
      id: 1,
      question: 'Listeler nasıl indekslenir?',
      options: ['Sıfırdan', 'Birden', 'Rastgele', 'İndeks yoktur'],
    ),
    QuizQuestion(
      id: 2,
      question: 'Dart map anahtarları nasıl olmalıdır?',
      options: [
        'Tekrarlanabilir',
        'Benzersiz olmalıdır',
        'Sadece String',
        'Sıralı olmalıdır',
      ],
    ),
  ],
);

void main() {
  testWidgets('submits answers and navigates to detailed result screen', (
    tester,
  ) async {
    final repository = _FakeNotesRepository();
    repository.submissionCompleter = Completer<QuizSubmissionResult>();
    final viewModel = await _openQuiz(tester, repository);

    expect(find.text('Soru 1 / 2'), findsOneWidget);
    expect(find.text('Soru 2 / 2'), findsOneWidget);
    expect(find.text('Test kodu: quiz-1'), findsOneWidget);
    expect(find.text('0 / 2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final completeButton = find.text('Testi Tamamla ve Değerlendir');
    expect(completeButton, findsOneWidget);
    expect(_buttonFor(tester, completeButton).onPressed, isNull);

    await _selectOption(tester, 'Sıfırdan');
    expect(viewModel.quizAnswers, {1: 'Sıfırdan'});
    expect(find.text('1 / 2'), findsOneWidget);

    await _selectOption(tester, 'Birden');
    expect(viewModel.quizAnswers, {1: 'Birden'});

    await _selectOption(tester, 'Sıfırdan');
    await _selectOption(tester, 'Benzersiz olmalıdır');
    expect(viewModel.quizAnswers, {1: 'Sıfırdan', 2: 'Benzersiz olmalıdır'});
    expect(_buttonFor(tester, completeButton).onPressed, isNotNull);

    await tester.tap(completeButton);
    await tester.pump();
    expect(viewModel.isSubmitting, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_buttonFor(tester, completeButton).onPressed, isNull);
    expect(repository.submitCallCount, 1);
    repository.submissionCompleter!.complete(_successfulResult);
    await tester.pumpAndSettle();

    expect(repository.submittedQuizId, 'quiz-1');
    expect(repository.submittedAnswers, {
      1: 'Sıfırdan',
      2: 'Benzersiz olmalıdır',
    });
    expect(find.byType(QuizResultScreen), findsOneWidget);
    expect(find.text('Test Sonuçları ve Çözüm Analizi'), findsOneWidget);
    expect(find.text('%100'), findsOneWidget);
    expect(find.text('Sizin cevabınız • Doğru cevap'), findsOneWidget);
    expect(find.text('İndeksler sıfırdan başlar.'), findsOneWidget);

    await tester.tap(find.text('Ders Notlarına Dön'));
    await tester.pumpAndSettle();
    expect(find.text('Notlar ekranı'), findsOneWidget);
  });

  testWidgets('shows an evaluation error and keeps the quiz available', (
    tester,
  ) async {
    final repository = _FakeNotesRepository()
      ..submissionError = const NetworkException('Bağlantı kesildi.');
    final viewModel = await _openQuiz(tester, repository);

    await _selectOption(tester, 'Sıfırdan');
    await _selectOption(tester, 'Benzersiz olmalıdır');
    await tester.tap(find.text('Testi Tamamla ve Değerlendir'));
    await tester.pumpAndSettle();

    expect(viewModel.isSubmitting, isFalse);
    expect(find.text('Bağlantı kesildi.'), findsOneWidget);
    expect(find.byType(QuizResultScreen), findsNothing);
    expect(
      _buttonFor(tester, find.text('Testi Tamamla ve Değerlendir')).onPressed,
      isNotNull,
    );
  });
}

class _FakeNotesRepository implements NotesRepository {
  String? submittedQuizId;
  Map<int, String>? submittedAnswers;
  int submitCallCount = 0;
  Completer<QuizSubmissionResult>? submissionCompleter;
  Object? submissionError;

  @override
  Future<QuizSubmissionResult> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) async {
    submitCallCount++;
    submittedQuizId = quizId;
    submittedAnswers = Map.of(answers);
    if (submissionError case final error?) throw error;
    return submissionCompleter?.future ?? _successfulResult;
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

Future<QuizSubmissionResult> get _successfulResult async =>
    QuizSubmissionResult(
      quizId: _quiz.quizId,
      totalQuestions: _quiz.questions.length,
      correctCount: 2,
      scorePercent: 100,
      results: [
        QuestionResult(
          id: 1,
          question: _quiz.questions[0].question,
          options: _quiz.questions[0].options,
          selectedAnswer: 'Sıfırdan',
          correctAnswer: 'Sıfırdan',
          isCorrect: true,
          explanation: 'İndeksler sıfırdan başlar.',
        ),
        QuestionResult(
          id: 2,
          question: _quiz.questions[1].question,
          options: _quiz.questions[1].options,
          selectedAnswer: 'Benzersiz olmalıdır',
          correctAnswer: 'Benzersiz olmalıdır',
          isCorrect: true,
          explanation: 'Map anahtarları benzersiz olmalıdır.',
        ),
      ],
    );

Future<NotesViewModel> _openQuiz(
  WidgetTester tester,
  _FakeNotesRepository repository,
) async {
  final viewModel = NotesViewModel(
    SummarizeLesson(repository),
    GenerateQuiz(repository),
    SubmitQuiz(repository),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: viewModel,
      child: MaterialApp(
        initialRoute: '/notes',
        routes: {
          '/notes': (_) => const Scaffold(body: Text('Notlar ekranı')),
          '/quiz': (_) => const QuizScreen(quiz: _quiz),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  Navigator.of(tester.element(find.text('Notlar ekranı'))).pushNamed('/quiz');
  await tester.pumpAndSettle();
  return viewModel;
}

FilledButton _buttonFor(WidgetTester tester, Finder text) {
  return tester.widget<FilledButton>(
    find.ancestor(of: text, matching: find.byType(FilledButton)),
  );
}

Future<void> _selectOption(WidgetTester tester, String option) async {
  final finder = find.text(option);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}
