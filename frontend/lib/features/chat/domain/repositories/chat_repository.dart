import '../entities/chat_message.dart';

/// Chat özelliğinin domain sözleşmesi.
abstract class ChatRepository {
  Future<ChatMessage> askQuestion(String question);
}
