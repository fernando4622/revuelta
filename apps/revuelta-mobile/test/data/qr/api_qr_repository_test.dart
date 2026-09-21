import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/data/api/api_client.dart';
import 'package:revuelta_mobile/data/qr/api_qr_repository.dart';
import 'package:revuelta_mobile/domain/qr/operation_qr.dart';

void main() {
  test('maps the approved QR API contract into typed models', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final data = switch (options.path) {
          '/me/operation-qrs' => <String, dynamic>{
              'tokenRef': '24a9d8dc-1afd-4f9b-aa76-c073dced7664',
              'purpose': 'RETURN',
              'payload': 'RV1:P:RETURN:signed',
              'issuedAt': '2026-09-20T20:00:00Z',
              'expiresAt': '2026-09-20T20:02:00Z',
            },
          '/operation-qr-resolutions' => <String, dynamic>{
              'tokenRef': '24a9d8dc-1afd-4f9b-aa76-c073dced7664',
              'participantRef': '5297ebde-6404-49b6-9a8b-d95ac738e361',
              'purpose': 'RETURN',
              'expiresAt': '2026-09-20T20:02:00Z',
              'eligibility': 'ELIGIBLE',
            },
          '/container-qr-resolutions' => <String, dynamic>{
              'containerRef': 'fb561e22-f4cc-4621-ab5c-b526f7efeaec',
              'displayCode': 'RV-0001',
              'state': 'IN_USE',
              'stateLabel': 'En uso',
              'eligibleForCirculation': false,
              'activeCirculation': <String, dynamic>{
                'circulationRef': '85a226e8-dd81-4364-8693-8ef1c4a3e437',
                'participantRef': '5297ebde-6404-49b6-9a8b-d95ac738e361',
                'deliveredAt': '2026-09-20T19:00:00Z',
                'dueAt': '2026-09-22T19:00:00Z',
              },
              'allowedActions': <String>['RETURN'],
            },
          _ => throw StateError('Unexpected request: ${options.path}'),
        };
        handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: data,
        ));
      },
    ));
    final repository = ApiQrRepository(ApiClient(dioClient: dio));

    final generated = await repository
        .generateOperationQr(OperationQrPurpose.returnContainer);
    final participant =
        await repository.resolveOperationQr('RV1:P:RETURN:signed');
    final container = await repository.resolveContainerQr('RV1:C:signed');

    expect(generated.payload, 'RV1:P:RETURN:signed');
    expect(generated.purpose, OperationQrPurpose.returnContainer);
    expect(participant.participantRef, '5297ebde-6404-49b6-9a8b-d95ac738e361');
    expect(container.displayCode, 'RV-0001');
    expect(container.allowedActions, {'RETURN'});
    expect(container.activeCirculation?.dueAt,
        DateTime.parse('2026-09-22T19:00:00Z'));
  });
}
