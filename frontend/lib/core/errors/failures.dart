/// Domain katmanında kullanılan hata soyutlaması.
abstract class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Ağ bağlantısı kurulamadı.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Sunucu hatası oluştu.']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Beklenmeyen bir hata oluştu.']);
}
