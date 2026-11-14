import 'package:flutter/foundation.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/lesson_summary.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/usecases/generate_quiz.dart';
import '../../domain/usecases/summarize_lesson.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel(this._summarizeLesson, this._generateQuiz);

  final SummarizeLesson _summarizeLesson;
  final GenerateQuiz _generateQuiz;

  LessonSummary? _summary;
  bool _isLoading = false;
  String? _statusMessage;
  String? _errorMessage;

  LessonSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  Future<void> summarize({
    required String title,
    required String text,
  }) async {
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

  void clearSummary() {
    _summary = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _startLoading(String status) {
    _isLoading = true;
    _statusMessage = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _finishLoading({String? error}) {
    _isLoading = false;
    _statusMessage = null;
    _errorMessage = error;
    notifyListeners();
  }
}
