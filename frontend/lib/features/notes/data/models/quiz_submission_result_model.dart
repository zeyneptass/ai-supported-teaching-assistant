import 'dart:convert';

import '../../domain/entities/quiz_submission_result.dart';
import '../../domain/entities/quiz.dart';

class QuizSubmissionResultModel extends QuizSubmissionResult {
  const QuizSubmissionResultModel({
    required super.quizId,
    required super.totalQuestions,
    required super.correctCount,
    required super.scorePercent,
    required super.results,
  });

  factory QuizSubmissionResultModel.fromJson(
    Object? payload, {
    required Quiz quiz,
    required Map<int, String> answers,
  }) {
    final json = _normalizePayload(payload);
    final rawResults = _asList(json['results'] ?? json['questions']);
    final indexedResults = <int, Map<String, dynamic>>{};
    for (var index = 0; index < rawResults.length; index++) {
      final item = _asMap(rawResults[index]);
      if (item == null) continue;
      final id = _asInt(item['id'] ?? item['question_id'] ?? item['questionId']);
      if (id != null) indexedResults[id] = item;
    }

    final results = <QuestionResult>[];
    for (var index = 0; index < quiz.questions.length; index++) {
      final question = quiz.questions[index];
      final raw = indexedResults[question.id] ??
          (index < rawResults.length
              ? _asMap(rawResults[index])
              : null) ??
          const <String, dynamic>{};
      final selectedAnswer = _asString(
        raw['selected_answer'] ?? raw['user_answer'] ?? raw['answer'],
        fallback: answers[question.id] ?? '',
      );
      final correctAnswer = _asString(raw['correct_answer']);
      final rawIsCorrect = raw['is_correct'] ?? raw['isCorrect'];
      final isCorrect = _asBool(
        rawIsCorrect,
        fallback: correctAnswer.isNotEmpty &&
            selectedAnswer == correctAnswer,
      );
      final resolvedCorrectAnswer = correctAnswer.isNotEmpty
          ? correctAnswer
          : isCorrect
          ? selectedAnswer
          : '';
      final options = _asStringList(raw['options']);
      final explanation = _asString(raw['explanation']).trim();

      results.add(
        QuestionResult(
          id: question.id,
          question: _asString(raw['question'], fallback: question.question),
          options: options.isEmpty
              ? List<String>.unmodifiable(question.options)
              : options,
          selectedAnswer: selectedAnswer,
          correctAnswer: resolvedCorrectAnswer,
          isCorrect: isCorrect,
          explanation: explanation.isNotEmpty
              ? explanation
              : resolvedCorrectAnswer.isNotEmpty
              ? 'Doğru cevap: $resolvedCorrectAnswer'
              : 'Doğru cevap sunucu yanıtında belirtilmedi.',
        ),
      );
    }

    final derivedCorrectCount = results.where((item) => item.isCorrect).length;
    final parsedTotalQuestions = _asInt(
      json['total_questions'] ?? json['totalQuestions'],
    );
    final totalQuestions = parsedTotalQuestions == null ||
            parsedTotalQuestions <= 0
        ? quiz.questions.length
        : parsedTotalQuestions;
    final parsedCorrectCount =
        _asInt(json['correct_count'] ?? json['correctCount']) ??
        derivedCorrectCount;
    final correctCount = parsedCorrectCount.clamp(0, totalQuestions).toInt();
    final rawScore = json['score_percent'] ?? json['score'] ?? json['percentage'];
    final parsedScore = _asDouble(rawScore);
    final scorePercent = (parsedScore == null || !parsedScore.isFinite
            ? (totalQuestions == 0 ? 0 : correctCount * 100 / totalQuestions)
            : parsedScore)
        .clamp(0, 100)
        .toDouble();
    final quizId = _asString(
      json['quiz_id'] ?? json['quizId'],
      fallback: quiz.quizId,
    );

    return QuizSubmissionResultModel(
      quizId: quizId.isEmpty ? quiz.quizId : quizId,
      totalQuestions: totalQuestions,
      correctCount: correctCount,
      scorePercent: scorePercent,
      results: List<QuestionResult>.unmodifiable(results),
    );
  }

  static Map<String, dynamic> _normalizePayload(Object? payload) {
    Object? current = payload;
    for (var depth = 0; depth < 8; depth++) {
      if (current is String) {
        try {
          current = jsonDecode(current);
        } on FormatException {
          return const {};
        }
      }
      if (current is List) {
        current = current.isEmpty ? null : current.first;
        continue;
      }
      final map = _asMap(current);
      if (map == null) return const {};
      if (map.containsKey('data')) {
        current = map['data'];
        continue;
      }
      if (map.containsKey('body')) {
        current = map['body'];
        continue;
      }
      return map;
    }
    return _asMap(current) ?? const {};
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  static List<Object?> _asList(Object? value) {
    if (value is List) return value;
    final decoded = _decodeIfJson(value);
    return decoded is List ? decoded : const [];
  }

  static Object? _decodeIfJson(Object? value) {
    if (value is! String) return value;
    try {
      return jsonDecode(value);
    } on FormatException {
      return value;
    }
  }

  static String _asString(Object? value, {String fallback = ''}) {
    return value is String ? value : fallback;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static bool _asBool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return fallback;
  }

  static List<String> _asStringList(Object? value) {
    if (value is! List) return const [];
    return List<String>.unmodifiable(
      value.whereType<String>().where((item) => item.isNotEmpty),
    );
  }
}
