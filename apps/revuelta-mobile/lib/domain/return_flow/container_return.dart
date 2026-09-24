class ReturnContainerSummary {
  const ReturnContainerSummary({
    required this.id,
    required this.publicCode,
    required this.state,
    required this.stateLabel,
  });

  final String id;
  final String publicCode;
  final String state;
  final String stateLabel;
}

class ReturnPreview {
  const ReturnPreview({
    required this.circulationId,
    required this.participantRef,
    required this.container,
    required this.deliveredAt,
    required this.dueAt,
    required this.previewedAt,
    required this.traceId,
  });

  final String circulationId;
  final String participantRef;
  final ReturnContainerSummary container;
  final DateTime deliveredAt;
  final DateTime dueAt;
  final DateTime previewedAt;
  final String traceId;
}

class ReturnReceipt {
  const ReturnReceipt({
    required this.circulationId,
    required this.participantRef,
    required this.container,
    required this.returnedAt,
    required this.punctuality,
    required this.traceId,
  });

  final String circulationId;
  final String participantRef;
  final ReturnContainerSummary container;
  final DateTime returnedAt;
  final String punctuality;
  final String traceId;
}
