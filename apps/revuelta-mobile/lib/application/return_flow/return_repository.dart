import '../../domain/return_flow/container_return.dart';

abstract interface class ReturnRepository {
  Future<ReturnPreview> preview({
    required String participantQrPayload,
    required String containerQrPayload,
  });

  Future<ReturnReceipt> confirm({
    required String participantQrPayload,
    required String containerQrPayload,
  });
}
