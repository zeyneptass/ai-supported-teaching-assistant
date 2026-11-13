import 'package:flutter/foundation.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/ask_question.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._askQuestion);

  final AskQuestion _askQuestion;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendQuestion(String question) async {
    if (_isLoading) return;

    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    _errorMessage = null;
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: trimmed,
        role: MessageRole.user,
        createdAt: DateTime.now(),
      ),
    );
    _isLoading = true;
    notifyListeners();

    final result = await _askQuestion(trimmed);
    switch (result) {
      case Success(:final data):
        if (data.content.trim().isEmpty) {
          _errorMessage = 'Asistandan boş yanıt geldi.';
        } else {
          _messages.add(data);
        }
      case Error(:final failure):
        _errorMessage = failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
