import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/application/operations/role_experience_providers.dart';
import 'package:revuelta_mobile/application/operations/role_experience_repository.dart';
import 'package:revuelta_mobile/domain/failure/failure.dart';
import 'package:revuelta_mobile/domain/operations/role_experience.dart';

void main() {
  test('an uncertain wash result is not retried and refreshes visible state',
      () async {
    final repository = _NetworkFailingRepository();
    final container = ProviderContainer(overrides: [
      roleExperienceRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(washControllerProvider, (_, __) {});
    addTearDown(subscription.close);

    await container.read(washControllerProvider.future);
    final completed =
        await container.read(washControllerProvider.notifier).complete('c-1');

    expect(completed, isFalse);
    expect(repository.completeCalls, 1);
    expect(
      container.read(washControllerProvider).error,
      isA<OperationResultUncertainFailure>(),
    );
  });
}

class _NetworkFailingRepository implements RoleExperienceRepository {
  int completeCalls = 0;

  @override
  Future<WashReceipt> completeWash(String containerId) async {
    completeCalls++;
    throw const NetworkFailure();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
