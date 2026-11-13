import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: (json['answer'] ?? json['content'] ?? json['message'] ?? '')
          .toString(),
      role: MessageRole.assistant,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessageModel.assistant(String content) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      createdAt: DateTime.now(),
    );
  }
}
