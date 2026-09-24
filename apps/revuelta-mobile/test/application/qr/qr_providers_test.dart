import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/application/qr/qr_providers.dart';
import 'package:revuelta_mobile/application/qr/qr_repository.dart';
import 'package:revuelta_mobile/application/delivery/delivery_providers.dart';
import 'package:revuelta_mobile/application/delivery/delivery_repository.dart';
import 'package:revuelta_mobile/domain/delivery/delivery.dart';
import 'package:revuelta_mobile/domain/failure/failure.dart';
import 'package:revuelta_mobile/domain/qr/operation_qr.dart';
import 'package:revuelta_mobile/domain/qr/resolved_container_qr.dart';

void main() {
  test('repeated participant frames issue a single resolution request',
      () async {
    final repository = _FakeQrRepository();
    final container = ProviderContainer(
      overrides: [
        qrRepositoryProvider.overrideWithValue(repository),
        deliveryRepositoryProvider.overrideWithValue(_FakeDeliveryRepository()),
      ],
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

  test('delivery becomes ready only after both QR values and preview resolve',
      () async {
    final repository = _FakeQrRepository()
      ..participantCompleter.complete(_participant())
      ..containerCompleter.complete(_container());
    final delivery = _FakeDeliveryRepository();
    final container = ProviderContainer(
      overrides: [
        qrRepositoryProvider.overrideWithValue(repository),
        deliveryRepositoryProvider.overrideWithValue(delivery),
      ],
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
    expect(state.step, CafeteriaScanStep.review);
    expect(state.activity, CafeteriaScanActivity.ready);
    expect(state.participant, isNotNull);
    expect(state.container, isNotNull);
    expect(state.isPairCompatible, isTrue);
    expect(repository.containerResolutionCount, 1);
    expect(delivery.previewCount, 1);
    expect(delivery.lastParticipantPayload, 'participant-payload');
    expect(delivery.lastContainerPayload, 'container-payload');
  });

  test('confirm sends both scanned QR values once and clears them on success',
      () async {
    final qr = _FakeQrRepository()
      ..participantCompleter.complete(_participant())
      ..containerCompleter.complete(_container());
    final delivery = _FakeDeliveryRepository();
    final container = ProviderContainer(overrides: [
      qrRepositoryProvider.overrideWithValue(qr),
      deliveryRepositoryProvider.overrideWithValue(delivery),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(cafeteriaScanProvider, (_, __) {});
    addTearDown(subscription.close);

    final controller = container.read(cafeteriaScanProvider.notifier);
    controller.start();
    await controller.acceptPayload('participant-payload');
    await controller.acceptPayload('container-payload');
    await controller.confirmDelivery();

    final state = container.read(cafeteriaScanProvider);
    expect(delivery.deliveryCount, 1);
    expect(delivery.lastParticipantPayload, 'participant-payload');
    expect(delivery.lastContainerPayload, 'container-payload');
    expect(state.activity, CafeteriaScanActivity.success);
    expect(state.receipt, isNotNull);
    expect(state.participantQrPayload, isNull);
    expect(state.containerQrPayload, isNull);
  });

  test('network timeout is recovered by reading state without resubmitting',
      () async {
    final qr = _FakeQrRepository()
      ..participantCompleter.complete(_participant())
      ..containerCompleter.complete(_container())
      ..nextContainers.add(_inUseContainer());
    final delivery = _FakeDeliveryRepository()
      ..deliveryError = const NetworkFailure();
    final container = ProviderContainer(overrides: [
      qrRepositoryProvider.overrideWithValue(qr),
      deliveryRepositoryProvider.overrideWithValue(delivery),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(cafeteriaScanProvider, (_, __) {});
    addTearDown(subscription.close);

    final controller = container.read(cafeteriaScanProvider.notifier);
    controller.start();
    await controller.acceptPayload('participant-payload');
    await controller.acceptPayload('container-payload');
    await controller.confirmDelivery();
    expect(container.read(cafeteriaScanProvider).activity,
        CafeteriaScanActivity.uncertain);

    await controller.recoverUncertainDelivery();
    final recovered = container.read(cafeteriaScanProvider);
    expect(recovered.activity, CafeteriaScanActivity.success);
    expect(recovered.recoveredFromState, isTrue);
    expect(delivery.deliveryCount, 1);
    expect(qr.containerResolutionCount, 2);
  });

  test('participant generation sends the selected purpose to the repository',
      () async {
    final repository = _FakeQrRepository();
    final container = ProviderContainer(
      overrides: [
        qrRepositoryProvider.overrideWithValue(repository),
        deliveryRepositoryProvider.overrideWithValue(_FakeDeliveryRepository()),
      ],
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

ResolvedContainerQr _inUseContainer() => ResolvedContainerQr(
      containerRef: 'container-ref',
      displayCode: 'RV-0001',
      state: 'IN_USE',
      stateLabel: 'En uso',
      eligibleForCirculation: false,
      allowedActions: const {'RETURN'},
      activeCirculation: ActiveCirculationSummary(
        circulationRef: 'circulation-ref',
        participantRef: 'participant-ref',
        deliveredAt: DateTime.utc(2030),
        dueAt: DateTime.utc(2030, 1, 3),
      ),
    );

class _FakeQrRepository implements QrRepository {
  final participantCompleter = Completer<ResolvedOperationQr>();
  final containerCompleter = Completer<ResolvedContainerQr>();
  int participantResolutionCount = 0;
  int containerResolutionCount = 0;
  final nextContainers = <ResolvedContainerQr>[];
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
    if (nextContainers.isNotEmpty && containerResolutionCount > 1) {
      return Future.value(nextContainers.removeAt(0));
    }
    return containerCompleter.future;
  }

  @override
  Future<ResolvedOperationQr> resolveOperationQr(String payload) {
    participantResolutionCount++;
    return participantCompleter.future;
  }
}

class _FakeDeliveryRepository implements DeliveryRepository {
  int previewCount = 0;
  int deliveryCount = 0;
  String? lastParticipantPayload;
  String? lastContainerPayload;
  Object? deliveryError;

  @override
  Future<DeliveryPreview> preview({
    required String participantQrPayload,
    required String containerQrPayload,
  }) async {
    previewCount++;
    lastParticipantPayload = participantQrPayload;
    lastContainerPayload = containerQrPayload;
    return DeliveryPreview(
      participantRef: 'participant-ref',
      container: const DeliveryContainer(
        id: 'container-ref',
        publicCode: 'RV-0001',
        state: 'AVAILABLE',
      ),
      policy: const DeliveryPolicy(
        id: 'policy-ref',
        version: 2,
        name: 'Piloto 48h',
        durationHours: 48,
      ),
      previewedAt: DateTime.utc(2030),
      estimatedDueAt: DateTime.utc(2030, 1, 3),
      traceId: 'trace-ref',
    );
  }

  @override
  Future<DeliveryReceipt> deliver({
    required String participantQrPayload,
    required String containerQrPayload,
  }) async {
    deliveryCount++;
    lastParticipantPayload = participantQrPayload;
    lastContainerPayload = containerQrPayload;
    if (deliveryError case final error?) throw error;
    return DeliveryReceipt(
      circulationId: 'circulation-ref',
      participantRef: 'participant-ref',
      container: const DeliveryContainer(
        id: 'container-ref',
        publicCode: 'RV-0001',
        state: 'IN_USE',
      ),
      deliveredAt: DateTime.utc(2030),
      dueAt: DateTime.utc(2030, 1, 3),
      policy: const DeliveryPolicy(
        id: 'policy-ref',
        version: 2,
        name: 'Piloto 48h',
        durationHours: 48,
      ),
      traceId: 'trace-ref',
    );
  }
}
