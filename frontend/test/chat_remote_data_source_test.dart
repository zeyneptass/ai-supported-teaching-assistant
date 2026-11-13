import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/http_service_impl.dart';
import 'package:frontend/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sends message to ask webhook and reads response', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), ApiEndpoints.askWebhook);
      expect(jsonDecode(request.body), {'message': 'Python list nedir?'});
      return http.Response(
        jsonEncode({'response': 'Python list, sıralı bir koleksiyondur.'}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final dataSource = ChatRemoteDataSourceImpl(
      HttpServiceImpl(client: client),
    );

    final answer = await dataSource.askQuestion('Python list nedir?');

    expect(answer.content, 'Python list, sıralı bir koleksiyondur.');
  });
}
