import 'lesson_summary.dart';
import 'quiz.dart';
import 'quiz_submission_result.dart';

class SavedLesson {
  const SavedLesson({
    required this.summary,
    required this.sourceText,
    required this.updatedAt,
    required this.quizHistory,
  });

  final LessonSummary summary;
  final String sourceText;
  final DateTime updatedAt;
  final List<QuizHistoryEntry> quizHistory;

  String get id => summary.sourceId;
  String get title => summary.title;

  QuizHistoryEntry? get latestQuizHistory =>
      quizHistory.isEmpty ? null : quizHistory.last;

  Quiz? get latestQuiz => latestQuizHistory?.quiz;

  QuizSubmissionResult? get latestResult {
    for (final entry in quizHistory.reversed) {
      if (entry.result != null) return entry.result;
    }
    return null;
  }

  bool get isSummarized => summary.summary.trim().isNotEmpty;

  bool get hasSolvedQuiz => quizHistory.any((entry) => entry.result != null);
}

class QuizHistoryEntry {
  const QuizHistoryEntry({
    required this.quiz,
    required this.createdAt,
    this.result,
  });

  final Quiz quiz;
  final QuizSubmissionResult? result;
  final DateTime createdAt;
}
