import '../../application/return_flow/return_repository.dart';
import '../../domain/return_flow/container_return.dart';
import '../api/api_client.dart';

class ApiReturnRepository implements ReturnRepository {
  const ApiReturnRepository(this._client);

  final ApiClient _client;

  @override
  Future<ReturnPreview> preview({
    required String participantQrPayload,
    required String containerQrPayload,
  }) async {
    final json = await _client.post('/return-previews',
        data: _payloads(
          participantQrPayload,
          containerQrPayload,
        ));
    return ReturnPreview(
      circulationId: json['circulationId'] as String,
      participantRef: json['participantRef'] as String,
      container: _container(json['container'] as Map<String, dynamic>),
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      previewedAt: DateTime.parse(json['previewedAt'] as String),
      traceId: json['traceId'] as String,
    );
  }

  @override
  Future<ReturnReceipt> confirm({
    required String participantQrPayload,
    required String containerQrPayload,
  }) async {
    final json = await _client.post('/circulation-returns',
        data: _payloads(
          participantQrPayload,
          containerQrPayload,
        ));
    return ReturnReceipt(
      circulationId: json['circulationId'] as String,
      participantRef: json['participantRef'] as String,
      container: _container(json['container'] as Map<String, dynamic>),
      returnedAt: DateTime.parse(json['returnedAt'] as String),
      punctuality: json['punctuality'] as String,
      traceId: json['traceId'] as String,
    );
  }

  Map<String, dynamic> _payloads(String participant, String container) => {
        'participantQrPayload': participant,
        'containerQrPayload': container,
      };

  ReturnContainerSummary _container(Map<String, dynamic> json) =>
      ReturnContainerSummary(
        id: json['id'] as String,
        publicCode: json['publicCode'] as String,
        state: json['state'] as String,
        stateLabel: json['stateLabel'] as String,
      );
}
