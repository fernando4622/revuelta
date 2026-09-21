class ActiveCirculationSummary {
  const ActiveCirculationSummary({
    required this.circulationRef,
    required this.participantRef,
    required this.deliveredAt,
    required this.dueAt,
  });

  final String circulationRef;
  final String participantRef;
  final DateTime deliveredAt;
  final DateTime dueAt;
}

class ResolvedContainerQr {
  const ResolvedContainerQr({
    required this.containerRef,
    required this.displayCode,
    required this.state,
    required this.stateLabel,
    required this.eligibleForCirculation,
    required this.allowedActions,
    this.activeCirculation,
  });

  final String containerRef;
  final String displayCode;
  final String state;
  final String stateLabel;
  final bool eligibleForCirculation;
  final Set<String> allowedActions;
  final ActiveCirculationSummary? activeCirculation;
}
