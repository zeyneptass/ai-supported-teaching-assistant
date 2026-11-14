import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/quiz.dart';
import '../repositories/notes_repository.dart';

class GenerateQuiz {
  const GenerateQuiz(this._repository);

  final NotesRepository _repository;

  Future<Result<Quiz>> call({
    required String sourceId,
    required String title,
    required String text,
  }) async {
    if (sourceId.trim().isEmpty ||
        title.trim().isEmpty ||
        text.trim().isEmpty) {
      return const Error(
        UnexpectedFailure('Test oluşturmak için ders başlığı ve not gerekli.'),
      );
    }

    try {
      final quiz = await _repository.generateQuiz(
        sourceId: sourceId.trim(),
        title: title.trim(),
        text: text.trim(),
      );
      return Success(quiz);
    } on NetworkException catch (error) {
      return Error(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Error(ServerFailure(error.message));
    } catch (error) {
      return Error(UnexpectedFailure(error.toString()));
    }
  }
}
