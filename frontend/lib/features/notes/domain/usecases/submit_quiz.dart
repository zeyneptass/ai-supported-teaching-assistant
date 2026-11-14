import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/quiz.dart';
import '../entities/quiz_submission_result.dart';
import '../repositories/notes_repository.dart';

class SubmitQuiz {
  const SubmitQuiz(this._repository);

  final NotesRepository _repository;

  Future<Result<QuizSubmissionResult>> call({
    required String quizId,
    required Map<int, String> answers,
    required Quiz quiz,
  }) async {
    if (quizId.trim().isEmpty ||
        quiz.quizId != quizId ||
        answers.isEmpty ||
        quiz.questions.any((question) => !answers.containsKey(question.id))) {
      return const Error(
        UnexpectedFailure('Test ve tüm cevaplar gönderilmelidir.'),
      );
    }

    try {
      final result = await _repository.submitQuiz(
        quizId: quizId.trim(),
        answers: Map.unmodifiable(answers),
        quiz: quiz,
      );
      if (result.quizId != quizId.trim()) {
        return const Error(
          ServerFailure('Sunucu farklı bir test için sonuç döndürdü.'),
        );
      }
      final resultQuestionIds =
          result.results.map((item) => item.questionId).toSet();
      if (resultQuestionIds.length != result.results.length ||
      resultQuestionIds.length != answers.length ||
      !resultQuestionIds.containsAll(answers.keys) ||
      result.results.any(
        (item) => answers[item.questionId] != item.selectedAnswer,
      )) {
        return const Error(
          ServerFailure('Sunucudan tutarsız test sonuçları alındı.'),
        );
      }
      return Success(result);
    } on NetworkException catch (error) {
      return Error(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Error(ServerFailure(error.message));
    } catch (error) {
      return Error(UnexpectedFailure(error.toString()));
    }
  }
}
