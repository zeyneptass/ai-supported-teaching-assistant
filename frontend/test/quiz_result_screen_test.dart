import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notes/data/models/quiz_submission_result_model.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:frontend/features/notes/domain/entities/quiz_submission_result.dart';
import 'package:frontend/features/notes/presentation/screens/quiz_result_screen.dart';

void main() {
  testWidgets('shows wrong choice, correct option and solution explanation', (
    tester,
  ) async {
    const quiz = Quiz(
      quizId: 'quiz-1',
      title: 'Programlama',
      totalQuestions: 1,
      questions: [
        QuizQuestion(
          id: 1,
          question: 'Listeler nasıl indekslenir?',
          options: ['Sıfırdan', 'Birden', 'Rastgele', 'İndeks yoktur'],
        ),
      ],
    );
    const result = QuizSubmissionResult(
      quizId: 'quiz-1',
      totalQuestions: 1,
      correctCount: 0,
      scorePercent: 0,
      results: [
        QuestionResult(
          id: 1,
          question: 'Listeler nasıl indekslenir?',
          options: ['Birden', 'Rastgele', 'İndeks yoktur'],
          selectedAnswer: 'Birden',
          correctAnswer: 'Sıfırdan',
          isCorrect: false,
          explanation: 'Python listeleri sıfır tabanlı indekslenir.',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: QuizResultScreen(quiz: quiz, result: result),
      ),
    );

    expect(find.text('Yanlış'), findsNWidgets(2));
    expect(find.text('Birden'), findsOneWidget);
    expect(find.text('Sıfırdan'), findsOneWidget);
    expect(find.text('Sizin cevabınız'), findsOneWidget);
    expect(find.text('Doğru cevap'), findsOneWidget);
    expect(
      find.text('Python listeleri sıfır tabanlı indekslenir.'),
      findsOneWidget,
    );
    expect(find.text('Test başarıyla değerlendirildi.'), findsOneWidget);
    expect(find.text('Ders Notlarına Dön'), findsOneWidget);
  });

  testWidgets('shows a helpful empty state when analysis details are absent', (
    tester,
  ) async {
    const quiz = Quiz(
      quizId: 'quiz-empty-results',
      title: 'Programlama',
      totalQuestions: 1,
      questions: [
        QuizQuestion(
          id: 1,
          question: 'Listeler nasıl indekslenir?',
          options: ['Sıfırdan', 'Birden'],
        ),
      ],
    );
    const result = QuizSubmissionResult(
      quizId: 'quiz-empty-results',
      totalQuestions: 1,
      correctCount: 1,
      scorePercent: 100,
      results: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: QuizResultScreen(quiz: quiz, result: result),
      ),
    );

    expect(find.text('Test başarıyla değerlendirildi.'), findsOneWidget);
    expect(find.text('AI Öğretim Asistanı Çalışma Önerisi'), findsNothing);
    expect(
      find.text('Bu test için ayrıntılı çözüm bulunmuyor.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the evaluation feedback and server summary', (
    tester,
  ) async {
    const quiz = Quiz(
      quizId: 'quiz-evaluation',
      title: 'Quiz title',
      totalQuestions: 3,
      questions: [
        QuizQuestion(id: 1, question: 'Bir?', options: ['A', 'B']),
        QuizQuestion(id: 2, question: 'İki?', options: ['A', 'B']),
        QuizQuestion(id: 3, question: 'Üç?', options: ['A', 'B']),
      ],
    );
    final result = QuizSubmissionResultModel.fromJson(
      {
        'quiz_id': 'quiz-evaluation',
        'title': 'Endpoint başlığı',
        'total_questions': 3,
        'correct_count': 2,
        'wrong_count': 1,
        'score': 67,
        'feedback': 'Eksik kalan konuları yeniden gözden geçir.',
        'details': [
          {
            'question_id': 1,
            'question': 'Bir?',
            'user_answer': 'A',
            'correct_answer': 'A',
            'is_correct': true,
          },
          {
            'question_id': 2,
            'question': 'İki?',
            'user_answer': 'A',
            'correct_answer': 'B',
            'is_correct': true,
          },
          {
            'question_id': 3,
            'question': 'Üç?',
            'user_answer': 'A',
            'correct_answer': 'B',
            'is_correct': false,
          },
        ],
      },
      quiz: quiz,
      answers: const {1: 'A', 2: 'A', 3: 'A'},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: QuizResultScreen(quiz: quiz, result: result),
      ),
    );

    expect(find.text('Endpoint başlığı'), findsOneWidget);
    expect(find.text('AI Öğretim Asistanı Çalışma Önerisi'), findsOneWidget);
    expect(
      find.text('Eksik kalan konuları yeniden gözden geçir.'),
      findsOneWidget,
    );
    expect(result.results.map((item) => item.isCorrect), [true, true, false]);
    expect(find.text('Test başarıyla değerlendirildi.'), findsOneWidget);
  });
}
