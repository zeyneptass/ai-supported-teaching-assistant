import '../../domain/entities/lesson_summary.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_submission_result.dart';
import '../../domain/entities/saved_lesson.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_data_source.dart';
import '../datasources/notes_remote_data_source.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final NotesRemoteDataSource _remoteDataSource;
  final NotesLocalDataSource _localDataSource;

  @override
  Future<List<SavedLesson>> getSavedLessons() {
    return _localDataSource.getSavedLessons();
  }

  @override
  Future<LessonSummary> summarizeLesson({
    required String title,
    required String text,
  }) async {
    final summary = await _remoteDataSource.summarizeLesson(
      title: title,
      text: text,
    );
    await _localDataSource.saveSummary(summary: summary, sourceText: text);
    return summary;
  }

  @override
  Future<Quiz> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) async {
    final quiz = await _remoteDataSource.generateQuiz(
      sourceId: sourceId,
      title: title,
      text: text,
    );
    await _localDataSource.saveQuiz(
      sourceId: sourceId,
      title: title,
      sourceText: text,
      quiz: quiz,
    );
    return quiz;
  }

  @override
  Future<QuizSubmissionResult> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) async {
    final result = await _remoteDataSource.submitQuiz(
      quizId: quizId,
      answers: answers,
      quiz: quiz,
    );
    await _localDataSource.saveQuizResult(result);
    return result;
  }
}
