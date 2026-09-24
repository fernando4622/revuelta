class DeliveryContainer {
  const DeliveryContainer({
    required this.id,
    required this.publicCode,
    required this.state,
  });

  final String id;
  final String publicCode;
  final String state;
}

class DeliveryPolicy {
  const DeliveryPolicy({
    required this.id,
    required this.version,
    required this.name,
    required this.durationHours,
  });

  final String id;
  final int version;
  final String name;
  final int durationHours;
}

class DeliveryPreview {
  const DeliveryPreview({
    required this.participantRef,
    required this.container,
    required this.policy,
    required this.previewedAt,
    required this.estimatedDueAt,
    required this.traceId,
  });

  final String participantRef;
  final DeliveryContainer container;
  final DeliveryPolicy policy;
  final DateTime previewedAt;
  final DateTime estimatedDueAt;
  final String traceId;
}

class DeliveryReceipt {
  const DeliveryReceipt({
    required this.circulationId,
    required this.participantRef,
    required this.container,
    required this.deliveredAt,
    required this.dueAt,
    required this.policy,
    required this.traceId,
  });

  final String circulationId;
  final String participantRef;
  final DeliveryContainer container;
  final DateTime deliveredAt;
  final DateTime dueAt;
  final DeliveryPolicy policy;
  final String traceId;
}
