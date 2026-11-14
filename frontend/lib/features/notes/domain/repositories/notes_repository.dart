import '../entities/lesson_summary.dart';
import '../entities/quiz.dart';

abstract interface class NotesRepository {
  Future<LessonSummary> summarizeLesson({
    required String title,
    required String text,
  });

  Future<Quiz> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  });
}
