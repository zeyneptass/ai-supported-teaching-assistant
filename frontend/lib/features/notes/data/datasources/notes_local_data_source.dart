import '../../domain/entities/lesson_summary.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_submission_result.dart';
import '../../domain/entities/saved_lesson.dart';

abstract interface class NotesLocalDataSource {
  Future<List<SavedLesson>> getSavedLessons();

  Future<void> saveSummary({
    required LessonSummary summary,
    required String sourceText,
  });

  Future<void> saveQuiz({
    required String sourceId,
    required String title,
    required String sourceText,
    required Quiz quiz,
  });

  Future<void> saveQuizResult(QuizSubmissionResult result);
}

class MockNotesLocalDataSource implements NotesLocalDataSource {
  MockNotesLocalDataSource() : _lessons = _createInitialLessons();

  final List<SavedLesson> _lessons;

  @override
  Future<List<SavedLesson>> getSavedLessons() async {
    final lessons = List<SavedLesson>.of(_lessons)
      ..sort((first, second) => second.updatedAt.compareTo(first.updatedAt));
    return List.unmodifiable(lessons);
  }

  @override
  Future<void> saveSummary({
    required LessonSummary summary,
    required String sourceText,
  }) async {
    final index = _lessons.indexWhere(
      (lesson) => lesson.id == summary.sourceId,
    );
    final previous = index < 0 ? null : _lessons.removeAt(index);
    _lessons.add(
      SavedLesson(
        summary: summary,
        sourceText: sourceText,
        updatedAt: DateTime.now(),
        quizHistory: previous?.quizHistory ?? const [],
      ),
    );
  }

  @override
  Future<void> saveQuiz({
    required String sourceId,
    required String title,
    required String sourceText,
    required Quiz quiz,
  }) async {
    final index = _lessons.indexWhere((lesson) => lesson.id == sourceId);
    final previous = index < 0 ? null : _lessons.removeAt(index);
    final summary =
        previous?.summary ??
        LessonSummary(sourceId: sourceId, title: title, summary: '');
    final history = List<QuizHistoryEntry>.of(
      previous?.quizHistory ?? const [],
    );
    final existingIndex = history.lastIndexWhere(
      (entry) => entry.quiz.quizId == quiz.quizId && entry.result == null,
    );
    final entry = QuizHistoryEntry(quiz: quiz, createdAt: DateTime.now());
    if (existingIndex < 0) {
      history.add(entry);
    } else {
      history[existingIndex] = entry;
    }

    _lessons.add(
      SavedLesson(
        summary: summary,
        sourceText: sourceText,
        updatedAt: DateTime.now(),
        quizHistory: List.unmodifiable(history),
      ),
    );
  }

  @override
  Future<void> saveQuizResult(QuizSubmissionResult result) async {
    final lessonIndex = _lessons.indexWhere(
      (lesson) =>
          lesson.quizHistory.any((entry) => entry.quiz.quizId == result.quizId),
    );
    if (lessonIndex < 0) {
      throw StateError('Test ${result.quizId} kayıtlı derslerde bulunamadı.');
    }

    final lesson = _lessons.removeAt(lessonIndex);
    final quiz = lesson.quizHistory
        .lastWhere((entry) => entry.quiz.quizId == result.quizId)
        .quiz;
    final history = [
      ...lesson.quizHistory,
      QuizHistoryEntry(quiz: quiz, createdAt: DateTime.now(), result: result),
    ];
    _lessons.add(
      SavedLesson(
        summary: lesson.summary,
        sourceText: lesson.sourceText,
        updatedAt: DateTime.now(),
        quizHistory: List.unmodifiable(history),
      ),
    );
  }

  static List<SavedLesson> _createInitialLessons() {
    final cellQuiz = Quiz(
      quizId: 'mock-cell-quiz',
      title: 'Hücre ve Organeller Testi',
      totalQuestions: 2,
      questions: const [
        QuizQuestion(
          id: 1,
          question: 'Hücrenin enerji santrali olarak bilinen organel hangisi?',
          options: ['Mitokondri', 'Ribozom', 'Lizozom', 'Golgi aygıtı'],
        ),
        QuizQuestion(
          id: 2,
          question: 'Protein sentezinden sorumlu yapı hangisidir?',
          options: ['Çekirdek', 'Ribozom', 'Koful', 'Sentrozom'],
        ),
      ],
    );
    const cellResult = QuizSubmissionResult(
      quizId: 'mock-cell-quiz',
      totalQuestions: 2,
      correctCount: 2,
      scorePercent: 100,
      results: [
        QuestionResult(
          id: 1,
          question: 'Hücrenin enerji santrali olarak bilinen organel hangisi?',
          options: ['Mitokondri', 'Ribozom', 'Lizozom', 'Golgi aygıtı'],
          selectedAnswer: 'Mitokondri',
          correctAnswer: 'Mitokondri',
          isCorrect: true,
          explanation: 'Mitokondri hücre için kullanılabilir enerji üretir.',
        ),
        QuestionResult(
          id: 2,
          question: 'Protein sentezinden sorumlu yapı hangisidir?',
          options: ['Çekirdek', 'Ribozom', 'Koful', 'Sentrozom'],
          selectedAnswer: 'Ribozom',
          correctAnswer: 'Ribozom',
          isCorrect: true,
          explanation:
              'Ribozomlar protein sentezinin gerçekleştiği yapılardır.',
        ),
      ],
    );

    return [
      SavedLesson(
        summary: const LessonSummary(
          sourceId: 'mock-cell-biology',
          title: 'Hücre ve Organeller',
          summary:
              'Hücre, canlıların temel yapı birimidir. Mitokondri enerji '
              'üretir; ribozom protein sentezler; çekirdek ise kalıtsal '
              'bilgiyi yönetir.',
        ),
        sourceText:
            'Hücre canlıların temel yapı birimidir. Mitokondri enerji üretir. '
            'Ribozom protein sentezler. Çekirdek DNA içerir ve hücreyi yönetir.',
        updatedAt: DateTime(2026, 11, 14, 19, 30),
        quizHistory: [
          QuizHistoryEntry(
            quiz: cellQuiz,
            result: cellResult,
            createdAt: DateTime(2026, 11, 14, 19, 30),
          ),
        ],
      ),
      SavedLesson(
        summary: const LessonSummary(
          sourceId: 'mock-python-loops',
          title: 'Python Döngüleri',
          summary:
              'for döngüsü koleksiyonlar üzerinde dolaşır. while döngüsü '
              'koşul doğru kaldığı sürece çalışır; break ve continue akışı '
              'kontrol etmeye yardımcı olur.',
        ),
        sourceText:
            'Python for ve while döngülerini destekler. for koleksiyonlar '
            'üzerinde dolaşır, while koşul doğru oldukça çalışır. break '
            'döngüyü sonlandırır, continue sonraki adıma geçer.',
        updatedAt: DateTime(2026, 11, 13, 16, 0),
        quizHistory: [],
      ),
    ];
  }
}
