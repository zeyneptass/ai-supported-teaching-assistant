import '../../../../core/constants/api_endpoints.dart';
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
    final response = await _httpService.post(
      ApiEndpoints.askWebhook,
      body: {'question': question},
    );
    return ChatMessageModel.fromJson(response);
  }
}
