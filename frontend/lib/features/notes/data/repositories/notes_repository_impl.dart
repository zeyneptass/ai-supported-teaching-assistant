import '../../domain/entities/lesson_summary.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_submission_result.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_data_source.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._remoteDataSource);

  final NotesRemoteDataSource _remoteDataSource;

  @override
  Future<LessonSummary> summarizeLesson({
    required String title,
    required String text,
  }) {
    return _remoteDataSource.summarizeLesson(title: title, text: text);
  }

  @override
  Future<Quiz> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) {
    return _remoteDataSource.generateQuiz(
      sourceId: sourceId,
      title: title,
      text: text,
    );
  }

  @override
  Future<QuizSubmissionResult> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) {
    return _remoteDataSource.submitQuiz(
      quizId: quizId,
      answers: answers,
      quiz: quiz,
    );
  }
}
