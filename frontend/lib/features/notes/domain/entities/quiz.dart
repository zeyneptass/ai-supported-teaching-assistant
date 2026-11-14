class Quiz {
  const Quiz({
    required this.quizId,
    required this.title,
    required this.totalQuestions,
    required this.questions,
  });

  final String quizId;
  final String title;
  final int totalQuestions;
  final List<QuizQuestion> questions;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final int id;
  final String question;
  final List<String> options;
}
