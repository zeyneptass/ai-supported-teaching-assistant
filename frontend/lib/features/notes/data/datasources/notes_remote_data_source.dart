import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_service.dart';
import '../../domain/entities/quiz.dart';
import '../models/lesson_summary_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_result_model.dart';

abstract interface class NotesRemoteDataSource {
  Future<LessonSummaryModel> summarizeLesson({
    required String title,
    required String text,
  });

  Future<QuizModel> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  });

  Future<QuizSubmissionResultModel> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  });
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  NotesRemoteDataSourceImpl(this._httpService);

  final HttpService _httpService;

  @override
  Future<LessonSummaryModel> summarizeLesson({
    required String title,
    required String text,
  }) async {
    final json = await _httpService.post(
      ApiEndpoints.summarizeWebhook,
      body: {'title': title, 'text': text},
      timeout: const Duration(seconds: 120),
    );
    try {
      return LessonSummaryModel.fromJson(json);
    } on FormatException catch (error) {
      throw ServerException(error.message);
    }
  }

  @override
  Future<QuizModel> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final json = await _httpService.post(
          ApiEndpoints.generateQuizWebhook,
          body: {
            'source_id': sourceId,
            'title': title,
            'text': text,
          },
          timeout: const Duration(seconds: 120),
        );
        return QuizModel.fromJson(json);
      } catch (_) {
        if (attempt == 1) rethrow;
      }
    }

    throw const ServerException('Test oluşturulamadı.');
  }

  @override
  Future<QuizSubmissionResultModel> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) async {
    final json = await _httpService.post(
      ApiEndpoints.submitQuizWebhook,
      body: {
        'quiz_id': quizId,
        'answers': {
          for (final entry in answers.entries)
            entry.key.toString(): entry.value,
        },
      },
    );

    return QuizSubmissionResultModel.fromJson(
      json,
      quiz: quiz,
      answers: answers,
    );
  }
}
