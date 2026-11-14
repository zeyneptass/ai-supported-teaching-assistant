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
  final List<QuizQuestionResult> results;
}

class QuizQuestionResult {
  const QuizQuestionResult({
    required this.questionId,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  final int questionId;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;
}
