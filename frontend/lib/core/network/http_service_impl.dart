import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import 'http_service.dart';

class HttpServiceImpl implements HttpService {
  HttpServiceImpl({
    http.Client? client,
    this.timeout = const Duration(seconds: 150),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _handle(
      () => _client.get(
        Uri.parse(url),
        headers: {
          ..._jsonHeaders,
          ...?headers,
        },
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    return _handle(
      () => _client.post(
        Uri.parse(url),
        headers: {
          ..._jsonHeaders,
          ...?headers,
        },
        body: body == null ? null : jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> _handle(
    Future<http.Response> Function() request, {
    Duration? timeout,
  }) async {
    final requestTimeout = timeout ?? this.timeout;
    try {
      final response = await request().timeout(requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
      if (response.body.isEmpty) {
        return {};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    } on TimeoutException {
      throw NetworkException(
        'İstek zaman aşımına uğradı. Asistan yanıtı ${requestTimeout.inSeconds} saniyeyi aştı.',
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw NetworkException(error.toString());
    }
  }
}
