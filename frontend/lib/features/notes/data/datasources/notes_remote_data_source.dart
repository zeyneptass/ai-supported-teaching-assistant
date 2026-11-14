import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_service.dart';
import '../models/lesson_summary_model.dart';
import '../models/quiz_model.dart';

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
        );
        return QuizModel.fromJson(json);
      } catch (_) {
        if (attempt == 1) rethrow;
      }
    }

    throw const ServerException('Test oluşturulamadı.');
  }
}
