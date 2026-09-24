import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/data/api/api_client.dart';
import 'package:revuelta_mobile/data/return_flow/api_return_repository.dart';

void main() {
  test('maps preview and return while sending both complete scanned payloads',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      final isPreview = options.path == '/return-previews';
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{
          'circulationId': 'circulation-ref',
          'participantRef': 'participant-ref',
          'container': <String, dynamic>{
            'id': 'container-ref',
            'publicCode': 'RV-0001',
            'state': isPreview ? 'IN_USE' : 'RETURNED',
            'stateLabel': isPreview ? 'En uso' : 'Pendiente de lavado',
          },
          if (isPreview) ...<String, dynamic>{
            'deliveredAt': '2026-09-23T18:00:00Z',
            'dueAt': '2026-09-25T18:00:00Z',
            'previewedAt': '2026-09-24T18:00:00Z',
          } else ...<String, dynamic>{
            'returnedAt': '2026-09-24T18:01:00Z',
            'punctuality': 'ON_TIME',
          },
          'traceId': 'trace-ref',
        },
      ));
    }));
    final repository = ApiReturnRepository(ApiClient(dioClient: dio));

    final preview = await repository.preview(
      participantQrPayload: 'participant-signed',
      containerQrPayload: 'container-signed',
    );
    final receipt = await repository.confirm(
      participantQrPayload: 'participant-signed',
      containerQrPayload: 'container-signed',
    );

    expect(preview.container.state, 'IN_USE');
    expect(preview.circulationId, 'circulation-ref');
    expect(receipt.container.state, 'RETURNED');
    expect(receipt.punctuality, 'ON_TIME');
    for (final request in requests) {
      expect(request.data, <String, dynamic>{
        'participantQrPayload': 'participant-signed',
        'containerQrPayload': 'container-signed',
      });
    }
  });
}
