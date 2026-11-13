/// Veri katmanında fırlatılan istisnalar.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Ağ hatası.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Sunucu hatası.']);
}
