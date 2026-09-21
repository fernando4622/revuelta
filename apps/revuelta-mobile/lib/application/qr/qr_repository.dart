import '../../domain/qr/operation_qr.dart';
import '../../domain/qr/resolved_container_qr.dart';

abstract interface class QrRepository {
  Future<OperationQr> generateOperationQr(OperationQrPurpose purpose);

  Future<ResolvedOperationQr> resolveOperationQr(String payload);

  Future<ResolvedContainerQr> resolveContainerQr(String payload);
}
