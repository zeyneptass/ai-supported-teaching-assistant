import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';
import 'package:frontend/features/notes/presentation/screens/quiz_screen.dart';

void main() {
  testWidgets(
    'requires every answer and shows selected choices at completion',
    (tester) async {
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

      await tester.pumpWidget(const MaterialApp(home: QuizScreen(quiz: quiz)));

      final completeButton = find.text('Yanıtlanan: 0/1');
      expect(completeButton, findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(
                of: completeButton,
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.text('Sıfırdan'));
      await tester.pump();
      expect(find.text('Testi Tamamla'), findsOneWidget);

      await tester.tap(find.text('Testi Tamamla'));
      await tester.pumpAndSettle();
      expect(find.text('Test tamamlandı'), findsOneWidget);
      expect(find.text('Sıfırdan'), findsNWidgets(2));
    },
  );
}
