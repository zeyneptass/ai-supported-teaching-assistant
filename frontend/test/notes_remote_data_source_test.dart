import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/http_service.dart';
import 'package:frontend/core/network/http_service_impl.dart';
import 'package:frontend/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:frontend/features/notes/data/models/lesson_summary_model.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('summarize sends title and text and parses the summary', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), ApiEndpoints.summarizeWebhook);
      expect(jsonDecode(request.body), {
        'title': 'Programlama',
        'text': 'Ders notları',
      });
      return http.Response(
        jsonEncode({
          'source_id': 'source-1',
          'title': 'Programlama',
          'summary': 'Kısa özet',
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final dataSource = NotesRemoteDataSourceImpl(
      HttpServiceImpl(client: client),
    );

    final summary = await dataSource.summarizeLesson(
      title: 'Programlama',
      text: 'Ders notları',
    );

    expect(summary.sourceId, 'source-1');
    expect(summary.summary, 'Kısa özet');
  });

  test(
    'summarize parses Mongo ObjectId buffer as a hexadecimal source id',
    () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'source_id': {
              'buffer': {'0': 106, '1': 0, '2': 15, '3': 255},
            },
            'title': 'Programlama',
            'summary': 'Kısa özet',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final dataSource = NotesRemoteDataSourceImpl(
        HttpServiceImpl(client: client),
      );

      final summary = await dataSource.summarizeLesson(
        title: 'Programlama',
        text: 'Ders notları',
      );

      expect(summary.sourceId, '6a000fff');
    },
  );

  test('uses a non-empty source id fallback for an unusable buffer', () {
    final summary = LessonSummaryModel.fromJson({
      'source_id': {'buffer': <String, Object?>{}},
      'title': 'Programlama',
      'summary': 'Kısa özet',
    });

    expect(summary.sourceId, isNotEmpty);
  });

  test(
    'generate quiz retries once and does not model correct answers',
    () async {
      var attempts = 0;
      final client = MockClient((request) async {
        attempts++;
        expect(request.url.toString(), ApiEndpoints.generateQuizWebhook);
        expect(jsonDecode(request.body), {
          'source_id': 'source-1',
          'title': 'Programlama',
          'text': 'Ders notları',
        });
        if (attempts == 1) return http.Response('retry', 503);

        return http.Response(
          jsonEncode({
            'quiz_id': 'quiz-1',
            'title': 'Programlama',
            'questions': [
              {
                'id': 1,
                'question': 'Soru?',
                'options': ['A', 'B', 'C', 'D'],
                'correct_answer': 'A',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final dataSource = NotesRemoteDataSourceImpl(
        HttpServiceImpl(client: client),
      );

      final quiz = await dataSource.generateQuiz(
        sourceId: 'source-1',
        title: 'Programlama',
        text: 'Ders notları',
      );

      expect(attempts, 2);
      expect(quiz.quizId, 'quiz-1');
      expect(quiz.totalQuestions, 1);
      expect(quiz.questions.single.options, ['A', 'B', 'C', 'D']);
    },
  );

  test(
    'submit quiz sends answer text and parses server grading result',
    () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), ApiEndpoints.evaluateQuizWebhook);
        expect(jsonDecode(request.body), {
          'quiz_id': 'quiz-1',
          'answers': {'1': 'Sıfırdan', '2': 'İndeks yoktur'},
        });
        return http.Response(
          jsonEncode({
            'quiz_id': 'quiz-1',
            'total_questions': 2,
            'correct_count': 1,
            'score_percent': 50,
            'results': [
              {
                'question_id': 1,
                'question': 'Birinci soru?',
                'selected_answer': 'Sıfırdan',
                'correct_answer': 'Sıfırdan',
                'is_correct': true,
                'explanation': 'İlk seçenek doğrudur.',
              },
              {
                'question_id': 2,
                'question': 'İkinci soru?',
                'selected_answer': 'İndeks yoktur',
                'correct_answer': 'Birden',
                'is_correct': false,
                'explanation': 'İndeksler sıfırdan başlar.',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final dataSource = NotesRemoteDataSourceImpl(
        HttpServiceImpl(client: client),
      );
      const quiz = Quiz(
        quizId: 'quiz-1',
        title: 'Programlama',
        totalQuestions: 2,
        questions: [
          QuizQuestion(
            id: 1,
            question: 'Birinci soru?',
            options: ['Sıfırdan', 'Birden', 'Rastgele', 'İndeks yoktur'],
          ),
          QuizQuestion(
            id: 2,
            question: 'İkinci soru?',
            options: ['Sıfırdan', 'Birden', 'Rastgele', 'İndeks yoktur'],
          ),
        ],
      );

      final result = await dataSource.submitQuiz(
        quizId: 'quiz-1',
        answers: {1: 'Sıfırdan', 2: 'İndeks yoktur'},
        quiz: quiz,
      );

      expect(result.correctCount, 1);
      expect(result.scorePercent, 50);
      expect(result.results.last.isCorrect, isFalse);
      expect(result.results.last.explanation, 'İndeksler sıfırdan başlar.');
    },
  );

  test('HTTP service defaults to a 120-second timeout', () {
    final service = HttpServiceImpl(
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(service.timeout, const Duration(seconds: 120));
  });

  test('evaluate request uses a 120-second timeout', () async {
    final service = _RecordingHttpService({'quiz_id': 'quiz-1'});
    final dataSource = NotesRemoteDataSourceImpl(service);
    const quiz = Quiz(
      quizId: 'quiz-1',
      title: 'Programlama',
      totalQuestions: 1,
      questions: [
        QuizQuestion(id: 1, question: 'Soru?', options: ['A', 'B', 'C', 'D']),
      ],
    );

    await dataSource.submitQuiz(
      quizId: 'quiz-1',
      answers: const {1: 'A'},
      quiz: quiz,
    );

    expect(service.timeout, const Duration(seconds: 120));
  });
}

class _RecordingHttpService implements HttpService {
  _RecordingHttpService(this.response);

  final Map<String, dynamic> response;
  Duration? timeout;

  @override
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    this.timeout = timeout;
    return response;
  }
}
