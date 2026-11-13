enum MessageRole { user, assistant }

/// Sohbet mesajının domain varlığı.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String content;
  final MessageRole role;
  final DateTime createdAt;
}
