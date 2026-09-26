import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/data/api/api_client.dart';
import 'package:revuelta_mobile/data/operations/api_role_experience_repository.dart';

void main() {
  test('maps participant circulation pages and preserves session-owned query',
      () async {
    late RequestOptions request;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      request = options;
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'items': [
            {
              'circulationId': 'circulation-1',
              'containerId': 'container-1',
              'publicCode': 'RV-0001',
              'containerState': 'IN_USE',
              'stateLabel': 'En uso',
              'deliveredAt': '2026-09-26T12:00:00Z',
              'dueAt': '2026-09-27T12:00:00Z',
              'returnedAt': null,
              'status': 'ACTIVE',
              'punctuality': null,
            }
          ],
          'page': 0,
          'size': 20,
          'hasNext': false,
        },
      ));
    }));
    final repository = ApiRoleExperienceRepository(ApiClient(dioClient: dio));

    final result = await repository.getMyCirculations(status: 'ACTIVE');

    expect(request.path, '/me/circulations');
    expect(request.queryParameters, containsPair('status', 'ACTIVE'));
    expect(request.queryParameters.containsKey('participantId'), isFalse);
    expect(result.items.single.publicCode, 'RV-0001');
    expect(result.items.single.dueAt.toUtc(),
        DateTime.parse('2026-09-27T12:00:00Z'));
  });

  test('completes washing without sending client state or time', () async {
    late RequestOptions request;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      request = options;
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'container': {
            'id': 'container-1',
            'publicCode': 'RV-0001',
            'state': 'AVAILABLE',
            'stateLabel': 'Disponible',
          },
          'washedAt': '2026-09-26T13:00:00Z',
          'traceId': 'trace-1',
        },
      ));
    }));
    final repository = ApiRoleExperienceRepository(ApiClient(dioClient: dio));

    final result = await repository.completeWash('container-1');

    expect(request.path, '/containers/container-1/wash-completions');
    expect(request.data, isNull);
    expect(result.state, 'AVAILABLE');
    expect(result.traceId, 'trace-1');
  });
}
