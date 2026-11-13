import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.createdAt,
  });

  factory ChatMessageModel.fromResponse(String content) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      createdAt: DateTime.now(),
    );
  }
}
