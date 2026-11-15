import '../entities/lesson_summary.dart';
import '../entities/quiz.dart';
import '../entities/quiz_submission_result.dart';
import '../entities/saved_lesson.dart';

abstract interface class NotesRepository {
  Future<List<SavedLesson>> getSavedLessons();

  Future<LessonSummary> summarizeLesson({
    required String title,
    required String text,
  });

  Future<Quiz> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  });

  Future<QuizSubmissionResult> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  });
}
