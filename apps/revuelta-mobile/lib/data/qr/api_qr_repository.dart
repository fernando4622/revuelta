import '../../application/qr/qr_repository.dart';
import '../../domain/qr/operation_qr.dart';
import '../../domain/qr/resolved_container_qr.dart';
import '../api/api_client.dart';

class ApiQrRepository implements QrRepository {
  const ApiQrRepository(this._client);

  final ApiClient _client;

  @override
  Future<OperationQr> generateOperationQr(OperationQrPurpose purpose) async {
    final json = await _client.post(
      '/me/operation-qrs',
      data: {'purpose': purpose.wireName},
    );
    return OperationQr(
      tokenRef: json['tokenRef'] as String,
      purpose: OperationQrPurpose.fromWire(json['purpose'] as String),
      payload: json['payload'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  @override
  Future<ResolvedOperationQr> resolveOperationQr(String payload) async {
    final json = await _client.post(
      '/operation-qr-resolutions',
      data: {'payload': payload},
    );
    return ResolvedOperationQr(
      tokenRef: json['tokenRef'] as String,
      participantRef: json['participantRef'] as String,
      purpose: OperationQrPurpose.fromWire(json['purpose'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  @override
  Future<ResolvedContainerQr> resolveContainerQr(String payload) async {
    final json = await _client.post(
      '/container-qr-resolutions',
      data: {'payload': payload},
    );
    final activeJson = json['activeCirculation'] as Map<String, dynamic>?;
    return ResolvedContainerQr(
      containerRef: json['containerRef'] as String,
      displayCode: json['displayCode'] as String,
      state: json['state'] as String,
      stateLabel: json['stateLabel'] as String,
      eligibleForCirculation: json['eligibleForCirculation'] as bool,
      allowedActions:
          (json['allowedActions'] as List<dynamic>).cast<String>().toSet(),
      activeCirculation: activeJson == null
          ? null
          : ActiveCirculationSummary(
              circulationRef: activeJson['circulationRef'] as String,
              participantRef: activeJson['participantRef'] as String,
              deliveredAt: DateTime.parse(activeJson['deliveredAt'] as String),
              dueAt: DateTime.parse(activeJson['dueAt'] as String),
            ),
    );
  }
}
