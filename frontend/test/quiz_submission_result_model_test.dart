import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notes/data/models/quiz_submission_result_model.dart';
import 'package:frontend/features/notes/domain/entities/quiz.dart';

void main() {
  const quiz = Quiz(
    quizId: 'quiz-1',
    title: 'Programlama',
    totalQuestions: 2,
    questions: [
      QuizQuestion(
        id: 1,
        question: 'Birinci soru?',
        options: ['A', 'B', 'C', 'D'],
      ),
      QuizQuestion(
        id: 2,
        question: 'İkinci soru?',
        options: ['W', 'X', 'Y', 'Z'],
      ),
    ],
  );
  const answers = {1: 'A', 2: 'Y'};

  test('parses direct maps, singleton lists, data and body wrappers', () {
    final response = {
      'quiz_id': 'quiz-1',
      'total_questions': 2,
      'correct_count': 1,
      'score_percent': 50,
      'results': [
        {
          'id': 1,
          'question': 'Birinci soru?',
          'options': ['A', 'B', 'C', 'D'],
          'selected_answer': 'A',
          'correct_answer': 'A',
          'is_correct': true,
        },
        {
          'id': 2,
          'question': 'İkinci soru?',
          'selected_answer': 'Y',
          'correct_answer': 'X',
          'is_correct': false,
        },
      ],
    };

    final variants = <Object?>[
      response,
      [response],
      {'data': response},
      {
        'body': jsonEncode({
          'data': [response],
        }),
      },
    ];

    for (final variant in variants) {
      final result = QuizSubmissionResultModel.fromJson(
        variant,
        quiz: quiz,
        answers: answers,
      );
      expect(result.quizId, 'quiz-1');
      expect(result.correctCount, 1);
      expect(result.results, hasLength(2));
      expect(result.results.first.options, ['A', 'B', 'C', 'D']);
      expect(result.results.last.options, ['W', 'X', 'Y', 'Z']);
      expect(result.results.last.explanation, 'Doğru cevap: X');
    }
  });

  test(
    'uses available quiz and answer data when response fields are missing',
    () {
      final result = QuizSubmissionResultModel.fromJson(
        {'body': <String, Object?>{}},
        quiz: quiz,
        answers: answers,
      );

      expect(result.quizId, quiz.quizId);
      expect(result.totalQuestions, 2);
      expect(result.correctCount, 0);
      expect(result.scorePercent, 0);
      expect(result.results.map((item) => item.id), [1, 2]);
      expect(result.results.first.options, ['A', 'B', 'C', 'D']);
      expect(result.results.first.selectedAnswer, 'A');
      expect(
        result.results.first.explanation,
        'Doğru cevap sunucu yanıtında belirtilmedi.',
      );
    },
  );

  test('parses n8n evaluation details and summary fields', () {
    const evaluationQuiz = Quiz(
      quizId: 'quiz-evaluation',
      title: 'Quiz title',
      totalQuestions: 3,
      questions: [
        QuizQuestion(id: 1, question: 'Bir?', options: ['A: doğru', 'B']),
        QuizQuestion(id: 2, question: 'İki?', options: ['A', 'B: doğru']),
        QuizQuestion(id: 3, question: 'Üç?', options: ['A', 'B: doğru']),
      ],
    );
    final result = QuizSubmissionResultModel.fromJson(
      {
        'quiz_id': 'quiz-evaluation',
        'title': 'Sunucu başlığı',
        'total_questions': 3,
        'correct_count': 2,
        'wrong_count': 1,
        'score': 67,
        'feedback': 'İkinci konuya tekrar çalış.',
        'details': [
          {
            'question_id': 1,
            'question': 'Bir?',
            'user_answer': ' A: doğru ',
            'correct_answer': 'A: doğru',
            'is_correct': false,
          },
          {
            'question_id': 2,
            'question': 'İki?',
            'user_answer': 'A',
            'correct_answer': 'B: doğru',
            'is_correct': true,
          },
          {
            'question_id': 3,
            'question': 'Üç?',
            'user_answer': 'A',
            'correct_answer': 'B: doğru',
            'is_correct': false,
          },
        ],
      },
      quiz: evaluationQuiz,
      answers: const {1: ' A: doğru ', 2: 'A', 3: 'A'},
    );

    expect(result.title, 'Sunucu başlığı');
    expect(result.totalQuestions, 3);
    expect(result.correctCount, 2);
    expect(result.wrongCount, 1);
    expect(result.scorePercent, 67);
    expect(result.feedback, 'İkinci konuya tekrar çalış.');
    expect(result.results.map((item) => item.isCorrect), [true, true, false]);
    expect(result.results.first.selectedAnswer, ' A: doğru ');
    expect(result.results.first.correctAnswer, 'A: doğru');
  });

  test('accepts results and questions with camel-case detail fields', () {
    const evaluationQuiz = Quiz(
      quizId: 'quiz-aliases',
      title: 'Aliases',
      totalQuestions: 1,
      questions: [
        QuizQuestion(id: 7, question: 'Soru?', options: ['A', 'B']),
      ],
    );
    final responses = [
      {
        'results': [
          {
            'id': 7,
            'userAnswer': ' A ',
            'correctAnswer': 'A',
            'isCorrect': false,
          },
        ],
      },
      {
        'questions': [
          {
            'questionId': 7,
            'userAnswer': 'A',
            'correctAnswer': 'B',
            'isCorrect': true,
          },
        ],
      },
    ];

    for (final response in responses) {
      final result = QuizSubmissionResultModel.fromJson(
        response,
        quiz: evaluationQuiz,
        answers: const {7: 'A'},
      );
      expect(result.results, hasLength(1));
      expect(result.results.single.isCorrect, isTrue);
    }
  });
}
