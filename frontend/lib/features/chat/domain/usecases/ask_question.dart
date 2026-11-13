import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class AskQuestion {
  const AskQuestion(this._repository);

  final ChatRepository _repository;

  Future<Result<ChatMessage>> call(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return const Error(UnexpectedFailure('Soru boş olamaz.'));
    }

    try {
      final message = await _repository.askQuestion(trimmed);
      return Success(message);
    } on NetworkException catch (error) {
      return Error(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Error(ServerFailure(error.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }
}
