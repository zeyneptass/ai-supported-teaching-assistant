import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('Ders Notlarına Dön'), findsOneWidget);
  });
}
