import '../../application/operations/role_experience_repository.dart';
import '../../domain/operations/role_experience.dart';
import '../api/api_client.dart';

class ApiRoleExperienceRepository implements RoleExperienceRepository {
  ApiRoleExperienceRepository(this._client);

  final ApiClient _client;

  @override
  Future<PagedResult<ParticipantCirculation>> getMyCirculations({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final data = await _client.get('/me/circulations', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'size': size,
    });
    return _page(data, _participantCirculation);
  }

  @override
  Future<PagedResult<PendingWash>> getPendingWashes(
      {int page = 0, int size = 20}) async {
    final data =
        await _client.get('/operator/pending-washes', queryParameters: {
      'page': page,
      'size': size,
    });
    return _page(
        data,
        (json) => PendingWash(
              containerId: json['containerId'] as String,
              publicCode: json['publicCode'] as String,
              state: json['state'] as String,
              stateLabel: json['stateLabel'] as String,
              returnedAt: DateTime.parse(json['returnedAt'] as String),
            ));
  }

  @override
  Future<PagedResult<OperatorOperation>> getRecentOperations(
      {int page = 0, int size = 20}) async {
    final data =
        await _client.get('/operator/recent-operations', queryParameters: {
      'page': page,
      'size': size,
    });
    return _page(
        data,
        (json) => OperatorOperation(
              eventId: json['eventId'] as String,
              eventType: json['eventType'] as String,
              containerId: json['containerId'] as String,
              publicCode: json['publicCode'] as String,
              occurredAt: DateTime.parse(json['occurredAt'] as String),
              resultingState: json['resultingState'] as String,
              traceId: json['traceId'] as String,
            ));
  }

  @override
  Future<WashReceipt> completeWash(String containerId) async {
    final data =
        await _client.post('/containers/$containerId/wash-completions');
    final container = data['container'] as Map<String, dynamic>;
    return WashReceipt(
      containerId: container['id'] as String,
      publicCode: container['publicCode'] as String,
      state: container['state'] as String,
      washedAt: DateTime.parse(data['washedAt'] as String),
      traceId: data['traceId'] as String,
    );
  }

  @override
  Future<OperationsSummary> getOperationsSummary() async {
    final data = await _client.get('/operations/summary');
    return OperationsSummary(
      totalContainers: data['totalContainers'] as int,
      registered: data['registered'] as int,
      available: data['available'] as int,
      inUse: data['inUse'] as int,
      returned: data['returned'] as int,
      damaged: data['damaged'] as int,
      lost: data['lost'] as int,
      retired: data['retired'] as int,
      activeCirculations: data['activeCirculations'] as int,
    );
  }

  @override
  Future<PagedResult<ParticipantDirectoryItem>> getParticipants(
      {int page = 0, int size = 20}) async {
    final data =
        await _client.get('/operations/participants', queryParameters: {
      'page': page,
      'size': size,
    });
    return _page(
        data,
        (json) => ParticipantDirectoryItem(
              participantRef: json['participantRef'] as String,
              active: json['active'] as bool,
              createdAt: DateTime.parse(json['createdAt'] as String),
            ));
  }

  @override
  Future<PagedResult<ContainerRecord>> getContainers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final data = await _client.get('/containers', queryParameters: {
      if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      if (status != null) 'status': status,
      'page': page,
      'size': size,
    });
    return _page(data, _container);
  }

  @override
  Future<ContainerRecord> registerContainer(String code) async {
    final data = await _client.post('/containers', data: {'code': code.trim()});
    return _container(data);
  }

  @override
  Future<ContainerRecord> activateContainer(String containerId) async {
    final data = await _client.post('/containers/$containerId/activate', data: {
      'reason': 'Activación operativa del piloto',
    });
    return _container(data);
  }

  @override
  Future<PagedResult<OperationsCirculation>> getOperationsCirculations({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final data =
        await _client.get('/operations/circulations', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'size': size,
    });
    return _page(
        data,
        (json) => OperationsCirculation(
              circulationId: json['circulationId'] as String,
              participantRef: json['participantRef'] as String,
              containerId: json['containerId'] as String,
              publicCode: json['publicCode'] as String,
              status: json['status'] as String,
              deliveredAt: DateTime.parse(json['deliveredAt'] as String),
              dueAt: DateTime.parse(json['dueAt'] as String),
              returnedAt: _date(json['returnedAt']),
              punctuality: json['punctuality'] as String?,
            ));
  }

  @override
  Future<PagedResult<OperationsEvent>> getOperationsEvents({
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    final data = await _client.get('/operations/events', queryParameters: {
      if (type != null) 'type': type,
      'page': page,
      'size': size,
    });
    return _page(
        data,
        (json) => OperationsEvent(
              eventId: json['eventId'] as String,
              eventType: json['eventType'] as String,
              containerId: json['containerId'] as String,
              publicCode: json['publicCode'] as String,
              actorId: json['actorId'] as String,
              occurredAt: DateTime.parse(json['occurredAt'] as String),
              previousStatus: json['previousStatus'] as String?,
              newStatus: json['newStatus'] as String,
              reason: json['reason'] as String?,
              traceId: json['traceId'] as String,
              participantRef: json['participantRef'] as String?,
              circulationRef: json['circulationRef'] as String?,
            ));
  }

  ParticipantCirculation _participantCirculation(Map<String, dynamic> json) {
    return ParticipantCirculation(
      circulationId: json['circulationId'] as String,
      containerId: json['containerId'] as String,
      publicCode: json['publicCode'] as String,
      containerState: json['containerState'] as String,
      stateLabel: json['stateLabel'] as String,
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      returnedAt: _date(json['returnedAt']),
      status: json['status'] as String,
      punctuality: json['punctuality'] as String?,
    );
  }

  ContainerRecord _container(Map<String, dynamic> json) => ContainerRecord(
        id: json['id'] as String,
        code: json['code'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        eligibleForCirculation: json['eligibleForCirculation'] as bool,
      );

  PagedResult<T> _page<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => mapper(item as Map<String, dynamic>))
        .toList(growable: false);
    return PagedResult(
      items: items,
      page: json['page'] as int,
      size: json['size'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }

  DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}
