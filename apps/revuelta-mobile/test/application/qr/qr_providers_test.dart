import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/application/qr/qr_providers.dart';
import 'package:revuelta_mobile/application/qr/qr_repository.dart';
import 'package:revuelta_mobile/domain/qr/operation_qr.dart';
import 'package:revuelta_mobile/domain/qr/resolved_container_qr.dart';

void main() {
  test('repeated participant frames issue a single resolution request',
      () async {
    final repository = _FakeQrRepository();
    final container = ProviderContainer(
      overrides: [qrRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(cafeteriaScanProvider, (_, __) {});
    addTearDown(subscription.close);

    final controller = container.read(cafeteriaScanProvider.notifier);
    controller.start();
    final first = controller.acceptPayload('participant-payload');
    final repeated = controller.acceptPayload('participant-payload');

    expect(repository.participantResolutionCount, 1);
    repository.participantCompleter.complete(_participant());
    await Future.wait([first, repeated]);

    final state = container.read(cafeteriaScanProvider);
    expect(state.step, CafeteriaScanStep.container);
    expect(state.activity, CafeteriaScanActivity.scanning);
  });

  test('flow completes only after participant and container are resolved',
      () async {
    final repository = _FakeQrRepository()
      ..participantCompleter.complete(_participant())
      ..containerCompleter.complete(_container());
    final container = ProviderContainer(
      overrides: [qrRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(cafeteriaScanProvider, (_, __) {});
    addTearDown(subscription.close);

    final controller = container.read(cafeteriaScanProvider.notifier);
    controller.start();
    await controller.acceptPayload('participant-payload');

    expect(container.read(cafeteriaScanProvider).step,
        CafeteriaScanStep.container);

    await controller.acceptPayload('container-payload');
    final state = container.read(cafeteriaScanProvider);
    expect(state.step, CafeteriaScanStep.complete);
    expect(state.participant, isNotNull);
    expect(state.container, isNotNull);
    expect(state.isPairCompatible, isTrue);
    expect(repository.containerResolutionCount, 1);
  });

  test('participant generation sends the selected purpose to the repository',
      () async {
    final repository = _FakeQrRepository();
    final container = ProviderContainer(
      overrides: [qrRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(operationQrProvider, (_, __) {});
    addTearDown(subscription.close);

    await container
        .read(operationQrProvider.notifier)
        .generate(OperationQrPurpose.returnContainer);

    expect(repository.generatedPurpose, OperationQrPurpose.returnContainer);
    expect(container.read(operationQrProvider).value?.payload, 'dynamic-qr');
  });
}

ResolvedOperationQr _participant() => ResolvedOperationQr(
      tokenRef: 'token-ref',
      participantRef: 'participant-ref',
      purpose: OperationQrPurpose.delivery,
      expiresAt: DateTime.utc(2030),
    );

ResolvedContainerQr _container() => const ResolvedContainerQr(
      containerRef: 'container-ref',
      displayCode: 'RV-0001',
      state: 'AVAILABLE',
      stateLabel: 'Disponible',
      eligibleForCirculation: true,
      allowedActions: {'DELIVER'},
    );

class _FakeQrRepository implements QrRepository {
  final participantCompleter = Completer<ResolvedOperationQr>();
  final containerCompleter = Completer<ResolvedContainerQr>();
  int participantResolutionCount = 0;
  int containerResolutionCount = 0;
  OperationQrPurpose? generatedPurpose;

  @override
  Future<OperationQr> generateOperationQr(OperationQrPurpose purpose) async {
    generatedPurpose = purpose;
    return OperationQr(
      tokenRef: 'token-ref',
      purpose: purpose,
      payload: 'dynamic-qr',
      issuedAt: DateTime.utc(2029, 12, 31, 23, 59),
      expiresAt: DateTime.utc(2030),
    );
  }

  @override
  Future<ResolvedContainerQr> resolveContainerQr(String payload) {
    containerResolutionCount++;
    return containerCompleter.future;
  }

  @override
  Future<ResolvedOperationQr> resolveOperationQr(String payload) {
    participantResolutionCount++;
    return participantCompleter.future;
  }
}
