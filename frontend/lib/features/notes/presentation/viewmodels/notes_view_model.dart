import 'package:flutter/foundation.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/lesson_summary.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_submission_result.dart';
import '../../domain/usecases/generate_quiz.dart';
import '../../domain/usecases/summarize_lesson.dart';
import '../../domain/usecases/submit_quiz.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel(this._summarizeLesson, this._generateQuiz, this._submitQuiz);

  final SummarizeLesson _summarizeLesson;
  final GenerateQuiz _generateQuiz;
  final SubmitQuiz _submitQuiz;

  LessonSummary? _summary;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _statusMessage;
  String? _errorMessage;
  String? _activeQuizId;
  final Map<int, String> _quizAnswers = {};

  LessonSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  Map<int, String> get quizAnswers => Map.unmodifiable(_quizAnswers);

  void beginQuiz(Quiz quiz) {
    if (_activeQuizId == quiz.quizId) return;
    _activeQuizId = quiz.quizId;
    _quizAnswers.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void selectQuizAnswer({
    required Quiz quiz,
    required int questionId,
    required String answer,
  }) {
    if (_activeQuizId != quiz.quizId) beginQuiz(quiz);
    final question = quiz.questions.where((item) => item.id == questionId);
    if (question.isEmpty || !question.first.options.contains(answer)) return;
    if (_quizAnswers[questionId] == answer) return;

    _quizAnswers[questionId] = answer;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> summarize({required String title, required String text}) async {
    if (_isLoading) return;
    _startLoading('Notlarınız özetleniyor...');

    final result = await _summarizeLesson(title: title, text: text);
    switch (result) {
      case Success<LessonSummary>(:final data):
        _summary = data;
        _finishLoading();
      case Error<LessonSummary>(:final failure):
        _finishLoading(error: failure.message);
    }
  }

  Future<Quiz?> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) async {
    if (_isLoading) return null;
    _startLoading('Testiniz hazırlanıyor...');

    final result = await _generateQuiz(
      sourceId: sourceId,
      title: title,
      text: text,
    );
    switch (result) {
      case Success<Quiz>(:final data):
        _finishLoading();
        return data;
      case Error<Quiz>(:final failure):
        _finishLoading(error: failure.message);
        return null;
    }
  }

  Future<QuizSubmissionResult?> submitQuiz({
    required String quizId,
    required Quiz quiz,
  }) async {
    if (_isLoading || _isSubmitting) return null;
    if (_activeQuizId != quizId ||
        quiz.quizId != quizId ||
        quiz.questions.any((question) => !_quizAnswers.containsKey(question.id))) {
      _errorMessage = 'Lütfen tüm soruları yanıtlayın.';
      notifyListeners();
      return null;
    }

    _startLoading('Cevaplarınız kontrol ediliyor...', isSubmitting: true);

    final result = await _submitQuiz(
      quizId: quizId,
      answers: Map.unmodifiable(_quizAnswers),
      quiz: quiz,
    );
    switch (result) {
      case Success<QuizSubmissionResult>(:final data):
        _finishLoading();
        return data;
      case Error<QuizSubmissionResult>(:final failure):
        _finishLoading(error: failure.message);
        return null;
    }
  }

  void clearSummary() {
    _summary = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _startLoading(String status, {bool isSubmitting = false}) {
    _isLoading = true;
    _isSubmitting = isSubmitting;
    _statusMessage = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _finishLoading({String? error}) {
    _isLoading = false;
    _isSubmitting = false;
    _statusMessage = null;
    _errorMessage = error;
    notifyListeners();
  }
}
