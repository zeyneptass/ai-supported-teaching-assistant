import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/features/home/presentation/widgets/saved_lesson_card.dart';
import 'package:frontend/features/notes/domain/entities/lesson_summary.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:frontend/features/notes/domain/entities/quiz_submission_result.dart';
import 'package:frontend/features/notes/domain/entities/saved_lesson.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';
import 'package:frontend/features/notes/domain/usecases/generate_quiz.dart';
import 'package:frontend/features/notes/domain/usecases/get_saved_lessons.dart';
import 'package:frontend/features/notes/domain/usecases/submit_quiz.dart';
import 'package:frontend/features/notes/domain/usecases/summarize_lesson.dart';
import 'package:frontend/features/notes/presentation/screens/notes_screen.dart';
import 'package:frontend/features/notes/presentation/screens/quiz_screen.dart';
import 'package:frontend/features/notes/presentation/viewmodels/notes_view_model.dart';
import 'package:provider/provider.dart';

const _quiz = Quiz(
  quizId: 'dart-quiz',
  title: 'Dart Testi',
  totalQuestions: 1,
  questions: [
    QuizQuestion(
      id: 1,
      question: 'Dart kod blokları hangi karakterlerle çevrelenir?',
      options: [
        'Süslü parantezler',
        'Köşeli parantezler',
        'Tırnaklar',
        'Virgüller',
      ],
    ),
  ],
);

final _lessons = [
  SavedLesson(
    summary: const LessonSummary(
      sourceId: 'dart',
      title: 'Dart Temelleri',
      summary: 'Dart dilinin temel sözdizimi.',
    ),
    sourceText: 'Dart kod blokları süslü parantezlerle çevrelenir.',
    updatedAt: DateTime(2026, 11, 14),
    quizHistory: [
      QuizHistoryEntry(
        quiz: _quiz,
        createdAt: DateTime(2026, 11, 14),
        result: const QuizSubmissionResult(
          quizId: 'dart-quiz',
          totalQuestions: 1,
          correctCount: 1,
          scorePercent: 100,
          results: [],
        ),
      ),
    ],
  ),
  SavedLesson(
    summary: const LessonSummary(
      sourceId: 'python',
      title: 'Python Döngüleri',
      summary: 'for ve while döngülerinin kullanım alanları.',
    ),
    sourceText:
        'for koleksiyonlarda, while koşul temelli yinelemede kullanılır.',
    updatedAt: DateTime(2026, 11, 13),
    quizHistory: [],
  ),
];

Widget _buildHome({
  _FakeNotesRepository? repository,
  NotesViewModel? viewModel,
}) {
  final activeViewModel =
      viewModel ?? _createNotesViewModel(repository ?? _FakeNotesRepository());
  return ChangeNotifierProvider.value(
    value: activeViewModel,
    child: const MaterialApp(home: HomeScreen()),
  );
}

NotesViewModel _createNotesViewModel(NotesRepository repository) {
  return NotesViewModel(
    SummarizeLesson(repository),
    GenerateQuiz(repository),
    SubmitQuiz(repository),
    GetSavedLessons(repository),
  );
}

void main() {
  testWidgets('searches lesson titles and filters solved tests', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    expect(find.text('Merhaba, Zeynep 👋'), findsOneWidget);
    expect(find.text('Dart Temelleri'), findsWidgets);

    final searchField = find.descendant(
      of: find.byType(SearchBar),
      matching: find.byType(EditableText),
    );
    await tester.enterText(searchField, 'Python');
    await tester.pumpAndSettle();
    expect(find.text('Python Döngüleri'), findsOneWidget);
    expect(find.text('Dart Temelleri'), findsNothing);

    await tester.enterText(searchField, 'bulunmayacak ders');
    await tester.pumpAndSettle();
    expect(find.text('Ders notu bulunamadı'), findsOneWidget);

    await tester.tap(find.byTooltip('Aramayı temizle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testi Çözülenler'));
    await tester.pumpAndSettle();
    expect(find.text('Dart Temelleri'), findsWidgets);
    expect(find.text('Python Döngüleri'), findsNothing);
    expect(find.text('%100'), findsOneWidget);
  });

  testWidgets('completed test card does not show a continue label', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    expect(find.text('DEVAM ET'), findsNothing);
    expect(find.text('Testi Tekrar Çöz'), findsOneWidget);
  });

  testWidgets('replaying a completed test clears previous answers', (
    tester,
  ) async {
    final viewModel = _createNotesViewModel(_FakeNotesRepository());
    viewModel.beginQuiz(_quiz);
    viewModel.selectQuizAnswer(
      quiz: _quiz,
      questionId: 1,
      answer: 'Süslü parantezler',
    );
    expect(viewModel.quizAnswers, {1: 'Süslü parantezler'});

    await tester.pumpWidget(_buildHome(viewModel: viewModel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testi Tekrar Çöz'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizScreen), findsOneWidget);
    expect(viewModel.quizAnswers, isEmpty);
    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsNothing);
  });

  testWidgets('a saved lesson without a quiz opens prefilled notes', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    final searchField = find.descendant(
      of: find.byType(SearchBar),
      matching: find.byType(EditableText),
    );
    await tester.enterText(searchField, 'Python');
    await tester.pumpAndSettle();
    final pythonCard = find.descendant(
      of: find.byType(SavedLessonCard),
      matching: find.text('Python Döngüleri'),
    );
    await tester.tap(pythonCard);
    await tester.pumpAndSettle();
    expect(find.byType(NotesScreen), findsOneWidget);
    expect(find.text('Ders notu metni'), findsOneWidget);
    final noteField = tester.widget<TextFormField>(
      find.byType(TextFormField).last,
    );
    expect(
      noteField.controller?.text,
      'for koleksiyonlarda, while koşul temelli yinelemede kullanılır.',
    );
  });

  testWidgets('a solved lesson opens its quiz screen', (tester) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    final dartCard = find.descendant(
      of: find.byType(SavedLessonCard),
      matching: find.text('Dart Temelleri'),
    );
    await tester.tap(dartCard);
    await tester.pumpAndSettle();

    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.text('Dart Testi'), findsOneWidget);
  });

  testWidgets('new lesson action opens NotesScreen', (tester) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeni Ders Notu Ekle'));
    await tester.pumpAndSettle();

    expect(find.byType(NotesScreen), findsOneWidget);
    expect(find.text('Ders başlığı'), findsOneWidget);
  });

  testWidgets('shows a loading indicator while lessons are being fetched', (
    tester,
  ) async {
    final repository = _FakeNotesRepository()
      ..loadCompleter = Completer<List<SavedLesson>>();
    await tester.pumpWidget(_buildHome(repository: repository));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.loadCompleter!.complete(_lessons);
    await tester.pumpAndSettle();
    await _searchForLesson(tester, 'Python Döngüleri');
    expect(_lessonTitle('Python Döngüleri'), findsOneWidget);
  });

  testWidgets('shows a retry action when loading lessons fails', (
    tester,
  ) async {
    final repository = _FakeNotesRepository()
      ..loadError = StateError('Geçici bağlantı hatası');
    await tester.pumpWidget(_buildHome(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Ders listesi yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pumpAndSettle();
    await _searchForLesson(tester, 'Python Döngüleri');
    expect(_lessonTitle('Python Döngüleri'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no saved lessons', (
    tester,
  ) async {
    final repository = _FakeNotesRepository()..lessons.clear();
    await tester.pumpWidget(_buildHome(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Henüz ders notun yok'), findsOneWidget);
    expect(find.text('Yeni Ders Notu Ekle'), findsOneWidget);
  });

  testWidgets('summarized lesson appears on HomeScreen after returning', (
    tester,
  ) async {
    final repository = _FakeNotesRepository()..summaryFailureCount = 1;
    await tester.pumpWidget(_buildHome(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeni Ders Notu Ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Dart Koleksiyonları',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'Dart listeleri sıralı koleksiyonlardır.',
    );
    await tester.tap(find.text('Özetle'));
    await tester.pumpAndSettle();

    expect(find.text('Tekrar Dene'), findsOneWidget);
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pumpAndSettle();
    expect(find.text('Özet başarıyla oluşturuldu'), findsOneWidget);

    await tester.tap(find.byTooltip('Sohbete dön'));
    await tester.pumpAndSettle();
    await _searchForLesson(tester, 'Dart Koleksiyonları');
    expect(_lessonTitle('Dart Koleksiyonları'), findsOneWidget);
  });
}

Finder _lessonTitle(String title) => find.descendant(
  of: find.byType(SavedLessonCard),
  matching: find.text(title),
);

Future<void> _searchForLesson(WidgetTester tester, String title) async {
  final searchField = find.descendant(
    of: find.byType(SearchBar),
    matching: find.byType(EditableText),
  );
  await tester.enterText(searchField, title);
  await tester.pumpAndSettle();
}

class _FakeNotesRepository implements NotesRepository {
  List<SavedLesson> lessons = List.of(_lessons);
  Completer<List<SavedLesson>>? loadCompleter;
  Object? loadError;
  int summaryFailureCount = 0;

  @override
  Future<List<SavedLesson>> getSavedLessons() async {
    final error = loadError;
    if (error != null) {
      loadError = null;
      throw error;
    }
    return loadCompleter?.future ?? lessons;
  }

  @override
  Future<Quiz> generateQuiz({
    required String sourceId,
    required String title,
    required String text,
  }) async => _quiz;

  @override
  Future<QuizSubmissionResult> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) async => const QuizSubmissionResult(
    quizId: 'dart-quiz',
    totalQuestions: 1,
    correctCount: 1,
    scorePercent: 100,
    results: [],
  );

  @override
  Future<LessonSummary> summarizeLesson({
    required String title,
    required String text,
  }) async {
    if (summaryFailureCount > 0) {
      summaryFailureCount--;
      throw StateError('Özet alınamadı');
    }
    final summary = LessonSummary(
      sourceId: 'new-lesson',
      title: title,
      summary: 'Özet',
    );
    lessons.removeWhere((lesson) => lesson.id == summary.sourceId);
    lessons.add(
      SavedLesson(
        summary: summary,
        sourceText: text,
        updatedAt: DateTime.now(),
        quizHistory: const [],
      ),
    );
    return summary;
  }
}
