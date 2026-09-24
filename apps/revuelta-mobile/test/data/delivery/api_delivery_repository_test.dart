import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/data/api/api_client.dart';
import 'package:revuelta_mobile/data/delivery/api_delivery_repository.dart';

void main() {
  test('maps preview and delivery without replacing scanned QR values with IDs',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      final common = <String, dynamic>{
        'participantRef': 'participant-ref',
        'container': <String, dynamic>{
          'id': 'container-ref',
          'publicCode': 'RV-0001',
          'state': options.path == '/circulations' ? 'IN_USE' : 'AVAILABLE',
        },
        'policy': <String, dynamic>{
          'id': 'policy-ref',
          'version': 4,
          'name': 'Piloto 48h',
          'durationHours': 48,
        },
        'traceId': 'trace-ref',
      };
      final data = options.path == '/delivery-previews'
          ? <String, dynamic>{
              ...common,
              'previewedAt': '2026-09-23T18:00:00Z',
              'estimatedDueAt': '2026-09-25T18:00:00Z',
            }
          : <String, dynamic>{
              ...common,
              'circulationId': 'circulation-ref',
              'deliveredAt': '2026-09-23T18:01:00Z',
              'dueAt': '2026-09-25T18:01:00Z',
            };
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: options.path == '/circulations' ? 201 : 200,
        data: data,
      ));
    }));
    final repository = ApiDeliveryRepository(ApiClient(dioClient: dio));

    final preview = await repository.preview(
      participantQrPayload: 'participant-signed',
      containerQrPayload: 'container-signed',
    );
    final receipt = await repository.deliver(
      participantQrPayload: 'participant-signed',
      containerQrPayload: 'container-signed',
    );

    expect(preview.policy.durationHours, 48);
    expect(preview.estimatedDueAt, DateTime.parse('2026-09-25T18:00:00Z'));
    expect(receipt.container.state, 'IN_USE');
    expect(receipt.circulationId, 'circulation-ref');
    for (final request in requests) {
      expect(request.data, <String, dynamic>{
        'participantQrPayload': 'participant-signed',
        'containerQrPayload': 'container-signed',
      });
    }
  });
}
