import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/operations/api_role_experience_repository.dart';
import '../../domain/failure/failure.dart';
import '../../domain/operations/role_experience.dart';
import '../auth/auth_notifier.dart';
import 'role_experience_repository.dart';

final roleExperienceRepositoryProvider = Provider<RoleExperienceRepository>(
  (ref) => ApiRoleExperienceRepository(ref.watch(apiClientProvider)),
);

final myActiveCirculationsProvider =
    FutureProvider.autoDispose<PagedResult<ParticipantCirculation>>(
  (ref) => ref
      .watch(roleExperienceRepositoryProvider)
      .getMyCirculations(status: 'ACTIVE'),
);

final myCirculationsProvider = FutureProvider.autoDispose
    .family<PagedResult<ParticipantCirculation>, String?>(
  (ref, status) => ref
      .watch(roleExperienceRepositoryProvider)
      .getMyCirculations(status: status),
);

final pendingWashesProvider =
    FutureProvider.autoDispose<PagedResult<PendingWash>>(
  (ref) => ref.watch(roleExperienceRepositoryProvider).getPendingWashes(),
);

final recentOperatorOperationsProvider =
    FutureProvider.autoDispose<PagedResult<OperatorOperation>>(
  (ref) => ref.watch(roleExperienceRepositoryProvider).getRecentOperations(),
);

final operationsSummaryProvider = FutureProvider.autoDispose<OperationsSummary>(
  (ref) => ref.watch(roleExperienceRepositoryProvider).getOperationsSummary(),
);

final participantsProvider =
    FutureProvider.autoDispose<PagedResult<ParticipantDirectoryItem>>(
  (ref) => ref.watch(roleExperienceRepositoryProvider).getParticipants(),
);

final containersProvider =
    FutureProvider.autoDispose.family<PagedResult<ContainerRecord>, String>(
  (ref, query) =>
      ref.watch(roleExperienceRepositoryProvider).getContainers(query: query),
);

final operationsCirculationsProvider =
    FutureProvider.autoDispose<PagedResult<OperationsCirculation>>(
  (ref) =>
      ref.watch(roleExperienceRepositoryProvider).getOperationsCirculations(),
);

final operationsEventsProvider =
    FutureProvider.autoDispose<PagedResult<OperationsEvent>>(
  (ref) => ref.watch(roleExperienceRepositoryProvider).getOperationsEvents(),
);

final washControllerProvider =
    AutoDisposeAsyncNotifierProvider<WashController, WashReceipt?>(
        WashController.new);

class WashController extends AutoDisposeAsyncNotifier<WashReceipt?> {
  @override
  FutureOr<WashReceipt?> build() => null;

  Future<bool> complete(String containerId) async {
    state = const AsyncValue.loading();
    try {
      final receipt = await ref
          .read(roleExperienceRepositoryProvider)
          .completeWash(containerId);
      state = AsyncValue.data(receipt);
      ref.invalidate(pendingWashesProvider);
      ref.invalidate(recentOperatorOperationsProvider);
      return true;
    } on NetworkFailure catch (_, stackTrace) {
      state = AsyncValue.error(
        const OperationResultUncertainFailure(),
        stackTrace,
      );
      ref.invalidate(pendingWashesProvider);
      ref.invalidate(recentOperatorOperationsProvider);
      return false;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final containerMutationControllerProvider = AutoDisposeAsyncNotifierProvider<
    ContainerMutationController, ContainerRecord?>(
  ContainerMutationController.new,
);

class ContainerMutationController
    extends AutoDisposeAsyncNotifier<ContainerRecord?> {
  @override
  FutureOr<ContainerRecord?> build() => null;

  Future<bool> register(String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(roleExperienceRepositoryProvider).registerContainer(code),
    );
    _refreshOnSuccess();
    return state.hasValue;
  }

  Future<bool> activate(String containerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(roleExperienceRepositoryProvider)
          .activateContainer(containerId),
    );
    _refreshOnSuccess();
    return state.hasValue;
  }

  void _refreshOnSuccess() {
    if (!state.hasValue) return;
    ref.invalidate(containersProvider);
    ref.invalidate(operationsSummaryProvider);
    ref.invalidate(operationsEventsProvider);
  }
}
