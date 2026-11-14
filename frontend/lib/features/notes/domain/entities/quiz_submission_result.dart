class QuizSubmissionResult {
  const QuizSubmissionResult({
    required this.quizId,
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercent,
    required this.results,
  });

  final String quizId;
  final int totalQuestions;
  final int correctCount;
  final double scorePercent;
  final List<QuestionResult> results;
}

class QuestionResult {
  const QuestionResult({
    required this.id,
    required this.question,
    required this.options,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  final int id;
  final String question;
  final List<String> options;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  int get questionId => id;
}

typedef QuizQuestionResult = QuestionResult;
