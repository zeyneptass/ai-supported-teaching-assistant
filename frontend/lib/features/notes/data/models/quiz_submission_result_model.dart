import '../../domain/entities/quiz_submission_result.dart';

class QuizSubmissionResultModel extends QuizSubmissionResult {
  const QuizSubmissionResultModel({
    required super.quizId,
    required super.totalQuestions,
    required super.correctCount,
    required super.scorePercent,
    required super.results,
  });

  factory QuizSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    final quizId = json['quiz_id'];
    final totalQuestions = json['total_questions'];
    final correctCount = json['correct_count'];
    final rawScore = json['score_percent'];
    final rawResults = json['results'];
    final scorePercent = rawScore is num ? rawScore.toDouble() : null;

    if (quizId is! String ||
        totalQuestions is! int ||
        correctCount is! int ||
        scorePercent == null ||
        rawResults is! List) {
      throw const FormatException('Test sonucu beklenen biçimde değil.');
    }

    final results = rawResults.map((rawResult) {
      if (rawResult is! Map<String, dynamic>) {
        throw const FormatException('Soru sonucu beklenen biçimde değil.');
      }

      final rawQuestionId = rawResult['question_id'];
      final questionId = rawQuestionId is int
          ? rawQuestionId
          : int.tryParse('$rawQuestionId');
      final question = rawResult['question'];
      final selectedAnswer = rawResult['selected_answer'];
      final correctAnswer = rawResult['correct_answer'];
      final isCorrect = rawResult['is_correct'];
      final explanation = rawResult['explanation'];

      if (questionId == null ||
          question is! String ||
          selectedAnswer is! String ||
          correctAnswer is! String ||
          isCorrect is! bool ||
          explanation is! String) {
        throw const FormatException('Soru sonucu alanları eksik veya hatalı.');
      }

      return QuizQuestionResult(
        questionId: questionId,
        question: question,
        selectedAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
        isCorrect: isCorrect,
        explanation: explanation,
      );
    }).toList(growable: false);

    if (quizId.isEmpty ||
        totalQuestions <= 0 ||
        correctCount < 0 ||
        correctCount > totalQuestions ||
        results.length != totalQuestions ||
        scorePercent < 0 ||
        scorePercent > 100) {
      throw const FormatException('Test sonucu tutarlı değerler içermiyor.');
    }

    return QuizSubmissionResultModel(
      quizId: quizId,
      totalQuestions: totalQuestions,
      correctCount: correctCount,
      scorePercent: scorePercent,
      results: List<QuizQuestionResult>.unmodifiable(results),
    );
  }
}
