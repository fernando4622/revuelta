import '../../domain/operations/role_experience.dart';

abstract interface class RoleExperienceRepository {
  Future<PagedResult<ParticipantCirculation>> getMyCirculations({
    String? status,
    int page = 0,
    int size = 20,
  });

  Future<PagedResult<PendingWash>> getPendingWashes(
      {int page = 0, int size = 20});
  Future<PagedResult<OperatorOperation>> getRecentOperations(
      {int page = 0, int size = 20});
  Future<WashReceipt> completeWash(String containerId);
  Future<OperationsSummary> getOperationsSummary();
  Future<PagedResult<ParticipantDirectoryItem>> getParticipants(
      {int page = 0, int size = 20});
  Future<PagedResult<ContainerRecord>> getContainers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  });
  Future<ContainerRecord> registerContainer(String code);
  Future<ContainerRecord> activateContainer(String containerId);
  Future<PagedResult<OperationsCirculation>> getOperationsCirculations({
    String? status,
    int page = 0,
    int size = 20,
  });
  Future<PagedResult<OperationsEvent>> getOperationsEvents({
    String? type,
    int page = 0,
    int size = 20,
  });
}
