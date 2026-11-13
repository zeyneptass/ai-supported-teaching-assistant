/// Uygulama genelindeki API uç noktaları.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  /// Android emülatörde host makine localhost karşılığı.
  //static const String n8nBaseUrl = 'http://10.0.2.2:5678';
  static const String askEndpoint = 'http://localhost:5678';

  /// n8n sohbet webhook'u.
  static const String askWebhook = '$askEndpoint/webhook/ask';
}
