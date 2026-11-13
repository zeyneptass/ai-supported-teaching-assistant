/// HTTP istemcisi sözleşmesi. Somut implementasyonlar veri kaynaklarından gizlenir.
abstract class HttpService {
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  });
}
