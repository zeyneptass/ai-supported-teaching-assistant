import '../../domain/entities/quiz.dart';

class QuizModel extends Quiz {
  const QuizModel({
    required super.quizId,
    required super.title,
    required super.totalQuestions,
    required super.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final quizId = json['quiz_id'];
    final title = json['title'];
    final totalQuestions = json['total_questions'];
    final rawQuestions = json['questions'];

    if (quizId is! String ||
        title is! String ||
        totalQuestions is! int ||
        rawQuestions is! List) {
      throw const FormatException('Test yanıtı beklenen biçimde değil.');
    }

    final questions = rawQuestions.map((rawQuestion) {
      if (rawQuestion is! Map<String, dynamic>) {
        throw const FormatException('Test sorusu beklenen biçimde değil.');
      }

      final rawId = rawQuestion['id'];
      final question = rawQuestion['question'];
      final rawOptions = rawQuestion['options'];
      final id = rawId is int ? rawId : int.tryParse('$rawId');

      if (id == null ||
          question is! String ||
          rawOptions is! List ||
          rawOptions.length != 4 ||
          rawOptions.any((option) => option is! String)) {
        throw const FormatException(
          'Test sorusu dört geçerli seçenek içermelidir.',
        );
      }

      return QuizQuestion(
        id: id,
        question: question,
        options: List<String>.unmodifiable(rawOptions.cast<String>()),
      );
    }).toList(growable: false);

    final questionIds = questions.map((question) => question.id).toSet();
    if (questions.isEmpty ||
        totalQuestions != questions.length ||
        questionIds.length != questions.length) {
      throw const FormatException(
        'Test soruları eksik, yinelenen veya sayı ile uyumsuz.',
      );
    }

    return QuizModel(
      quizId: quizId,
      title: title,
      totalQuestions: totalQuestions,
      questions: List<QuizQuestion>.unmodifiable(questions),
    );
  }
}
