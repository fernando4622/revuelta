enum OperationQrPurpose {
  delivery('DELIVERY'),
  returnContainer('RETURN');

  const OperationQrPurpose(this.wireName);

  final String wireName;

  static OperationQrPurpose fromWire(String value) => switch (value) {
        'DELIVERY' => OperationQrPurpose.delivery,
        'RETURN' => OperationQrPurpose.returnContainer,
        _ => throw FormatException('Unsupported operation QR purpose: $value'),
      };
}

class OperationQr {
  const OperationQr({
    required this.tokenRef,
    required this.purpose,
    required this.payload,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String tokenRef;
  final OperationQrPurpose purpose;
  final String payload;
  final DateTime issuedAt;
  final DateTime expiresAt;
}

class ResolvedOperationQr {
  const ResolvedOperationQr({
    required this.tokenRef,
    required this.participantRef,
    required this.purpose,
    required this.expiresAt,
  });

  final String tokenRef;
  final String participantRef;
  final OperationQrPurpose purpose;
  final DateTime expiresAt;
}
