import '../../application/delivery/delivery_repository.dart';
import '../../domain/delivery/delivery.dart';
import '../api/api_client.dart';

class ApiDeliveryRepository implements DeliveryRepository {
  const ApiDeliveryRepository(this._client);

  final ApiClient _client;

  @override
  Future<DeliveryPreview> preview({
    required String participantQrPayload,
    required String containerQrPayload,
  }) async {
    final json = await _client.post('/delivery-previews', data: {
      'participantQrPayload': participantQrPayload,
      'containerQrPayload': containerQrPayload,
    });
    return DeliveryPreview(
      participantRef: json['participantRef'] as String,
      container: _container(json['container'] as Map<String, dynamic>),
      policy: _policy(json['policy'] as Map<String, dynamic>),
      previewedAt: DateTime.parse(json['previewedAt'] as String),
      estimatedDueAt: DateTime.parse(json['estimatedDueAt'] as String),
      traceId: json['traceId'] as String,
    );
  }

  @override
  Future<DeliveryReceipt> deliver({
    required String participantQrPayload,
    required String containerQrPayload,
  }) async {
    final json = await _client.post('/circulations', data: {
      'participantQrPayload': participantQrPayload,
      'containerQrPayload': containerQrPayload,
    });
    return DeliveryReceipt(
      circulationId: json['circulationId'] as String,
      participantRef: json['participantRef'] as String,
      container: _container(json['container'] as Map<String, dynamic>),
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      policy: _policy(json['policy'] as Map<String, dynamic>),
      traceId: json['traceId'] as String,
    );
  }

  DeliveryContainer _container(Map<String, dynamic> json) => DeliveryContainer(
        id: json['id'] as String,
        publicCode: json['publicCode'] as String,
        state: json['state'] as String,
      );

  DeliveryPolicy _policy(Map<String, dynamic> json) => DeliveryPolicy(
        id: json['id'] as String,
        version: json['version'] as int,
        name: json['name'] as String,
        durationHours: json['durationHours'] as int,
      );
}
