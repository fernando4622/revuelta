import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/data/api/api_client.dart';

void main() {
  test('uses the explicitly configured API base URL', () {
    final client = ApiClient(baseUrl: 'https://api.example.test/api/v1');

    expect(client.dio.options.baseUrl, 'https://api.example.test/api/v1');
  });
}
