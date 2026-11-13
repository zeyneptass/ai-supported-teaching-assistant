import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_service.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> askQuestion(String question);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this._httpService);

  final HttpService _httpService;

  @override
  Future<ChatMessageModel> askQuestion(String question) async {
    final json = await _httpService.post(
      ApiEndpoints.askWebhook,
      body: {'question': question},
    );

    final raw = json['response'];
    if (raw == null) {
      throw const ServerException(
        'Asistandan geçerli bir yanıt alınamadı (response alanı yok).',
      );
    }

    final content = raw.toString().trim();
    if (content.isEmpty) {
      throw const ServerException('Asistandan boş yanıt geldi.');
    }

    return ChatMessageModel.fromResponse(content);
  }
}
