/// Uygulama genelindeki API uç noktaları.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  static const String n8nBaseUrl = 'http://localhost:5678';

  /// n8n sohbet webhook'u.
  static const String askWebhook = '$n8nBaseUrl/webhook/ask';
}
