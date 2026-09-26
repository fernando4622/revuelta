class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  final List<T> items;
  final int page;
  final int size;
  final bool hasNext;
}

class ParticipantCirculation {
  const ParticipantCirculation({
    required this.circulationId,
    required this.containerId,
    required this.publicCode,
    required this.containerState,
    required this.stateLabel,
    required this.deliveredAt,
    required this.dueAt,
    required this.status,
    this.returnedAt,
    this.punctuality,
  });

  final String circulationId;
  final String containerId;
  final String publicCode;
  final String containerState;
  final String stateLabel;
  final DateTime deliveredAt;
  final DateTime dueAt;
  final DateTime? returnedAt;
  final String status;
  final String? punctuality;
}

class PendingWash {
  const PendingWash({
    required this.containerId,
    required this.publicCode,
    required this.state,
    required this.stateLabel,
    required this.returnedAt,
  });

  final String containerId;
  final String publicCode;
  final String state;
  final String stateLabel;
  final DateTime returnedAt;
}

class OperatorOperation {
  const OperatorOperation({
    required this.eventId,
    required this.eventType,
    required this.containerId,
    required this.publicCode,
    required this.occurredAt,
    required this.resultingState,
    required this.traceId,
  });

  final String eventId;
  final String eventType;
  final String containerId;
  final String publicCode;
  final DateTime occurredAt;
  final String resultingState;
  final String traceId;
}

class OperationsSummary {
  const OperationsSummary({
    required this.totalContainers,
    required this.registered,
    required this.available,
    required this.inUse,
    required this.returned,
    required this.damaged,
    required this.lost,
    required this.retired,
    required this.activeCirculations,
  });

  final int totalContainers;
  final int registered;
  final int available;
  final int inUse;
  final int returned;
  final int damaged;
  final int lost;
  final int retired;
  final int activeCirculations;
}

class ParticipantDirectoryItem {
  const ParticipantDirectoryItem({
    required this.participantRef,
    required this.active,
    required this.createdAt,
  });

  final String participantRef;
  final bool active;
  final DateTime createdAt;
}

class ContainerRecord {
  const ContainerRecord({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.eligibleForCirculation,
  });

  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool eligibleForCirculation;
}

class OperationsCirculation {
  const OperationsCirculation({
    required this.circulationId,
    required this.participantRef,
    required this.containerId,
    required this.publicCode,
    required this.status,
    required this.deliveredAt,
    required this.dueAt,
    this.returnedAt,
    this.punctuality,
  });

  final String circulationId;
  final String participantRef;
  final String containerId;
  final String publicCode;
  final String status;
  final DateTime deliveredAt;
  final DateTime dueAt;
  final DateTime? returnedAt;
  final String? punctuality;
}

class OperationsEvent {
  const OperationsEvent({
    required this.eventId,
    required this.eventType,
    required this.containerId,
    required this.publicCode,
    required this.actorId,
    required this.occurredAt,
    required this.newStatus,
    required this.traceId,
    this.previousStatus,
    this.reason,
    this.participantRef,
    this.circulationRef,
  });

  final String eventId;
  final String eventType;
  final String containerId;
  final String publicCode;
  final String actorId;
  final DateTime occurredAt;
  final String? previousStatus;
  final String newStatus;
  final String? reason;
  final String traceId;
  final String? participantRef;
  final String? circulationRef;
}

class WashReceipt {
  const WashReceipt({
    required this.containerId,
    required this.publicCode,
    required this.state,
    required this.washedAt,
    required this.traceId,
  });

  final String containerId;
  final String publicCode;
  final String state;
  final DateTime washedAt;
  final String traceId;
}
