import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:frontend/features/notes/data/models/lesson_summary_model.dart';
import 'package:frontend/features/notes/data/models/quiz_model.dart';
import 'package:frontend/features/notes/data/models/quiz_submission_result_model.dart';
import 'package:frontend/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:frontend/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:frontend/features/notes/domain/entities/quiz_submission_result.dart';
import 'package:frontend/features/notes/domain/usecases/generate_quiz.dart';
import 'package:frontend/features/notes/domain/usecases/get_saved_lessons.dart';
import 'package:frontend/features/notes/domain/usecases/submit_quiz.dart';
import 'package:frontend/features/notes/domain/usecases/summarize_lesson.dart';
import 'package:frontend/features/notes/presentation/viewmodels/notes_view_model.dart';

void main() {
  test(
    'summaries, generated quizzes, and scores update saved lesson history',
    () async {
      final repository = NotesRepositoryImpl(
        _FakeNotesRemoteDataSource(),
        MockNotesLocalDataSource(),
      );
      final viewModel = NotesViewModel(
        SummarizeLesson(repository),
        GenerateQuiz(repository),
        SubmitQuiz(repository),
        GetSavedLessons(repository),
      );

      await viewModel.loadSavedLessons();
      expect(viewModel.savedLessons, hasLength(2));

      const sourceText =
          'Dart listeleri sıralı ve değiştirilebilir yapılardır.';
      await viewModel.summarize(title: 'Dart Listeleri', text: sourceText);
      final savedSummary = viewModel.savedLessons.firstWhere(
        (lesson) => lesson.id == 'new-dart-lesson',
      );
      expect(savedSummary.sourceText, sourceText);
      expect(savedSummary.summary.summary, 'Listeler sıralı koleksiyonlardır.');

      final quiz = await viewModel.generateQuiz(
        sourceId: savedSummary.id,
        title: savedSummary.title,
        text: sourceText,
      );
      expect(quiz, isNotNull);
      expect(
        viewModel.savedLessons
            .firstWhere((lesson) => lesson.id == 'new-dart-lesson')
            .latestQuiz
            ?.quizId,
        'new-dart-quiz',
      );

      viewModel.beginQuiz(quiz!);
      viewModel.selectQuizAnswer(
        quiz: quiz,
        questionId: 1,
        answer: 'Sıralı koleksiyon',
      );
      final result = await viewModel.submitQuiz(
        quizId: quiz.quizId,
        quiz: quiz,
      );

      expect(result?.scorePercent, 100);
      final savedResult = viewModel.savedLessons.firstWhere(
        (lesson) => lesson.id == 'new-dart-lesson',
      );
      expect(savedResult.latestResult?.scorePercent, 100);
      expect(savedResult.quizHistory, hasLength(2));
    },
  );
}

class _FakeNotesRemoteDataSource implements NotesRemoteDataSource {
  @override
  Future<LessonSummaryModel> summarizeLesson({
    required String title,
    required String text,
  }) async => LessonSummaryModel(
    sourceId: 'new-dart-lesson',
    title: title,
    summary: 'Listeler sıralı koleksiyonlardır.',
  );

  @override
  Future<QuizModel> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) async => const QuizModel(
    quizId: 'new-dart-quiz',
    title: 'Dart Listeleri Testi',
    totalQuestions: 1,
    questions: [
      QuizQuestion(
        id: 1,
        question: 'Dart listeleri nasıl koleksiyonlardır?',
        options: [
          'Sıralı koleksiyon',
          'Sırasız koleksiyon',
          'Sadece sabit koleksiyon',
          'Anahtar-değer koleksiyonu',
        ],
      ),
    ],
  );

  @override
  Future<QuizSubmissionResultModel> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) async => QuizSubmissionResultModel(
    quizId: quizId,
    totalQuestions: 1,
    correctCount: 1,
    scorePercent: 100,
    results: [
      QuestionResult(
        id: 1,
        question: quiz.questions.single.question,
        options: quiz.questions.single.options,
        selectedAnswer: answers[1]!,
        correctAnswer: 'Sıralı koleksiyon',
        isCorrect: true,
        explanation: 'Listeler sıralı koleksiyonlardır.',
      ),
    ],
  );
}
