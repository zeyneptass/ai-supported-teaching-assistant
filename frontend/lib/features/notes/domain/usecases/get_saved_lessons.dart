import '../entities/saved_lesson.dart';
import '../repositories/notes_repository.dart';

class GetSavedLessons {
  const GetSavedLessons(this._repository);

  final NotesRepository _repository;

  Future<List<SavedLesson>> call() => _repository.getSavedLessons();
}
