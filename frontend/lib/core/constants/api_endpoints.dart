/// Uygulama genelindeki API uç noktaları.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  /// Android emülatörde host makine localhost karşılığı.
  //static const String n8nBaseUrl = 'http://10.0.2.2:5678';
  static const String askEndpoint = 'http://localhost:5678';

  /// n8n sohbet webhook'u.
  static const String askWebhook = '$askEndpoint/webhook/ask';

  /// n8n ders özeti webhook'u.
  static const String summarizeWebhook = '$askEndpoint/webhook/summarize';

  /// n8n test oluşturma webhook'u.
  static const String generateQuizWebhook = '$askEndpoint/webhook/generate-quiz';

  /// n8n test yanıtlarını değerlendirme webhook'u.
  static const String submitQuizWebhook = '$askEndpoint/webhook/submit-quiz';
}
