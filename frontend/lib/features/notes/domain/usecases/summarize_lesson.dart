import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/lesson_summary.dart';
import '../repositories/notes_repository.dart';

class SummarizeLesson {
  const SummarizeLesson(this._repository);

  final NotesRepository _repository;

  Future<Result<LessonSummary>> call({
    required String title,
    required String text,
  }) async {
    if (title.trim().isEmpty || text.trim().isEmpty) {
      return const Error(
        UnexpectedFailure('Ders başlığı ve not metni boş olamaz.'),
      );
    }

    try {
      final summary = await _repository.summarizeLesson(
        title: title.trim(),
        text: text.trim(),
      );
      return Success(summary);
    } on NetworkException catch (error) {
      return Error(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Error(ServerFailure(error.message));
    } catch (error) {
      return Error(UnexpectedFailure(error.toString()));
    }
  }
}
