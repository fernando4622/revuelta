import '../../domain/delivery/delivery.dart';

abstract interface class DeliveryRepository {
  Future<DeliveryPreview> preview({
    required String participantQrPayload,
    required String containerQrPayload,
  });

  Future<DeliveryReceipt> deliver({
    required String participantQrPayload,
    required String containerQrPayload,
  });
}
