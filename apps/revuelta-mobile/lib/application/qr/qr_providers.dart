import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/qr/api_qr_repository.dart';
import '../../domain/delivery/delivery.dart';
import '../../domain/failure/failure.dart';
import '../../domain/qr/operation_qr.dart';
import '../../domain/qr/resolved_container_qr.dart';
import '../../domain/return_flow/container_return.dart';
import '../auth/auth_notifier.dart';
import '../delivery/delivery_providers.dart';
import '../return_flow/return_providers.dart';
import 'qr_repository.dart';

final qrRepositoryProvider = Provider<QrRepository>(
  (ref) => ApiQrRepository(ref.watch(apiClientProvider)),
);

final operationQrProvider =
    AutoDisposeAsyncNotifierProvider<OperationQrController, OperationQr?>(
        OperationQrController.new);

class OperationQrController extends AutoDisposeAsyncNotifier<OperationQr?> {
  @override
  FutureOr<OperationQr?> build() => null;

  Future<void> generate(OperationQrPurpose purpose) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(qrRepositoryProvider).generateOperationQr(purpose),
    );
  }

  void clear() => state = const AsyncValue.data(null);
}

enum CafeteriaScanStep { participant, container, review, finished }

enum CafeteriaScanActivity {
  idle,
  scanning,
  resolving,
  previewing,
  ready,
  submitting,
  uncertain,
  success,
  failure,
}

class CafeteriaScanState {
  const CafeteriaScanState({
    this.step = CafeteriaScanStep.participant,
    this.activity = CafeteriaScanActivity.idle,
    this.participant,
    this.container,
    this.preview,
    this.receipt,
    this.returnPreview,
    this.returnReceipt,
    this.recoveredFromState = false,
    this.failure,
    this.participantQrPayload,
    this.containerQrPayload,
  });

  final CafeteriaScanStep step;
  final CafeteriaScanActivity activity;
  final ResolvedOperationQr? participant;
  final ResolvedContainerQr? container;
  final DeliveryPreview? preview;
  final DeliveryReceipt? receipt;
  final ReturnPreview? returnPreview;
  final ReturnReceipt? returnReceipt;
  final bool recoveredFromState;
  final Failure? failure;

  // Ephemeral proof retained only by the controller while one handoff is active.
  // Widgets must never render or log these values.
  final String? participantQrPayload;
  final String? containerQrPayload;

  bool get isPairCompatible {
    final requiredAction = switch (participant?.purpose) {
      OperationQrPurpose.delivery => 'DELIVER',
      OperationQrPurpose.returnContainer => 'RETURN',
      null => null,
    };
    return requiredAction != null &&
        container?.allowedActions.contains(requiredAction) == true;
  }

  bool get canConfirmDelivery =>
      step == CafeteriaScanStep.review &&
      activity == CafeteriaScanActivity.ready &&
      participant?.purpose == OperationQrPurpose.delivery &&
      preview != null &&
      participantQrPayload != null &&
      containerQrPayload != null;

  bool get canConfirmReturn =>
      step == CafeteriaScanStep.review &&
      activity == CafeteriaScanActivity.ready &&
      participant?.purpose == OperationQrPurpose.returnContainer &&
      returnPreview != null &&
      participantQrPayload != null &&
      containerQrPayload != null;
}

final cafeteriaScanProvider =
    AutoDisposeNotifierProvider<CafeteriaScanController, CafeteriaScanState>(
  CafeteriaScanController.new,
);

class CafeteriaScanController extends AutoDisposeNotifier<CafeteriaScanState> {
  @override
  CafeteriaScanState build() => const CafeteriaScanState();

  void start() {
    if (state.activity == CafeteriaScanActivity.resolving ||
        state.activity == CafeteriaScanActivity.previewing ||
        state.activity == CafeteriaScanActivity.submitting) {
      return;
    }
    state = CafeteriaScanState(
      step: state.step,
      activity: CafeteriaScanActivity.scanning,
      participant: state.participant,
      participantQrPayload: state.participantQrPayload,
    );
  }

  Future<void> acceptPayload(String payload) async {
    if (payload.trim().isEmpty ||
        state.activity != CafeteriaScanActivity.scanning ||
        state.step == CafeteriaScanStep.review ||
        state.step == CafeteriaScanStep.finished) {
      return;
    }

    final resolvingStep = state.step;
    final previous = state;
    state = CafeteriaScanState(
      step: resolvingStep,
      activity: CafeteriaScanActivity.resolving,
      participant: previous.participant,
      participantQrPayload: previous.participantQrPayload,
    );

    try {
      final repository = ref.read(qrRepositoryProvider);
      if (resolvingStep == CafeteriaScanStep.participant) {
        final participant = await repository.resolveOperationQr(payload);
        state = CafeteriaScanState(
          step: CafeteriaScanStep.container,
          activity: CafeteriaScanActivity.scanning,
          participant: participant,
          participantQrPayload: payload,
        );
        return;
      }

      final container = await repository.resolveContainerQr(payload);
      final participant = previous.participant!;
      final participantPayload = previous.participantQrPayload!;
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.previewing,
        participant: participant,
        container: container,
        participantQrPayload: participantPayload,
        containerQrPayload: payload,
      );

      if (!state.isPairCompatible) {
        state = CafeteriaScanState(
          step: CafeteriaScanStep.review,
          activity: CafeteriaScanActivity.idle,
          participant: participant,
          container: container,
        );
        return;
      }

      if (participant.purpose == OperationQrPurpose.delivery) {
        final preview = await ref.read(deliveryRepositoryProvider).preview(
              participantQrPayload: participantPayload,
              containerQrPayload: payload,
            );
        state = CafeteriaScanState(
          step: CafeteriaScanStep.review,
          activity: CafeteriaScanActivity.ready,
          participant: participant,
          container: container,
          preview: preview,
          participantQrPayload: participantPayload,
          containerQrPayload: payload,
        );
      } else {
        final preview = await ref.read(returnRepositoryProvider).preview(
              participantQrPayload: participantPayload,
              containerQrPayload: payload,
            );
        state = CafeteriaScanState(
          step: CafeteriaScanStep.review,
          activity: CafeteriaScanActivity.ready,
          participant: participant,
          container: container,
          returnPreview: preview,
          participantQrPayload: participantPayload,
          containerQrPayload: payload,
        );
      }
    } catch (error) {
      state = CafeteriaScanState(
        step: resolvingStep,
        activity: CafeteriaScanActivity.failure,
        participant: previous.participant,
        failure: _failure(error, 'No fue posible validar la operación.'),
        participantQrPayload: previous.participantQrPayload,
      );
    }
  }

  Future<void> confirmDelivery() async {
    if (!state.canConfirmDelivery) return;
    final pending = state;
    state = CafeteriaScanState(
      step: CafeteriaScanStep.review,
      activity: CafeteriaScanActivity.submitting,
      participant: pending.participant,
      container: pending.container,
      preview: pending.preview,
      participantQrPayload: pending.participantQrPayload,
      containerQrPayload: pending.containerQrPayload,
    );

    try {
      final receipt = await ref.read(deliveryRepositoryProvider).deliver(
            participantQrPayload: pending.participantQrPayload!,
            containerQrPayload: pending.containerQrPayload!,
          );
      state = CafeteriaScanState(
        step: CafeteriaScanStep.finished,
        activity: CafeteriaScanActivity.success,
        participant: pending.participant,
        container: pending.container,
        preview: pending.preview,
        receipt: receipt,
      );
    } catch (error) {
      final failure = _failure(error, 'No fue posible confirmar la entrega.');
      if (failure is NetworkFailure) {
        state = CafeteriaScanState(
          step: CafeteriaScanStep.review,
          activity: CafeteriaScanActivity.uncertain,
          participant: pending.participant,
          container: pending.container,
          preview: pending.preview,
          failure: failure,
          participantQrPayload: pending.participantQrPayload,
          containerQrPayload: pending.containerQrPayload,
        );
        return;
      }

      ResolvedContainerQr? refreshed = pending.container;
      if (failure is ConflictFailure) {
        try {
          refreshed = await ref
              .read(qrRepositoryProvider)
              .resolveContainerQr(pending.containerQrPayload!);
        } catch (_) {
          // The original typed conflict remains the authoritative result.
        }
      }
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.failure,
        participant: pending.participant,
        container: refreshed,
        preview: pending.preview,
        failure: failure,
      );
    }
  }

  Future<void> recoverUncertainDelivery() async {
    if (state.activity != CafeteriaScanActivity.uncertain ||
        state.containerQrPayload == null ||
        state.participant == null) {
      return;
    }
    final pending = state;
    state = CafeteriaScanState(
      step: CafeteriaScanStep.review,
      activity: CafeteriaScanActivity.resolving,
      participant: pending.participant,
      container: pending.container,
      preview: pending.preview,
      participantQrPayload: pending.participantQrPayload,
      containerQrPayload: pending.containerQrPayload,
    );
    try {
      final refreshed = await ref
          .read(qrRepositoryProvider)
          .resolveContainerQr(pending.containerQrPayload!);
      final active = refreshed.activeCirculation;
      if (refreshed.state == 'IN_USE' &&
          active?.participantRef == pending.participant!.participantRef) {
        state = CafeteriaScanState(
          step: CafeteriaScanStep.finished,
          activity: CafeteriaScanActivity.success,
          participant: pending.participant,
          container: refreshed,
          preview: pending.preview,
          recoveredFromState: true,
        );
        return;
      }

      final preview = await ref.read(deliveryRepositoryProvider).preview(
            participantQrPayload: pending.participantQrPayload!,
            containerQrPayload: pending.containerQrPayload!,
          );
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.ready,
        participant: pending.participant,
        container: refreshed,
        preview: preview,
        participantQrPayload: pending.participantQrPayload,
        containerQrPayload: pending.containerQrPayload,
      );
    } catch (error) {
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.uncertain,
        participant: pending.participant,
        container: pending.container,
        preview: pending.preview,
        failure: _failure(error, 'Aún no pudimos confirmar el resultado.'),
        participantQrPayload: pending.participantQrPayload,
        containerQrPayload: pending.containerQrPayload,
      );
    }
  }

  Future<void> confirmReturn() async {
    if (!state.canConfirmReturn) return;
    final pending = state;
    state = CafeteriaScanState(
      step: CafeteriaScanStep.review,
      activity: CafeteriaScanActivity.submitting,
      participant: pending.participant,
      container: pending.container,
      returnPreview: pending.returnPreview,
      participantQrPayload: pending.participantQrPayload,
      containerQrPayload: pending.containerQrPayload,
    );

    try {
      final receipt = await ref.read(returnRepositoryProvider).confirm(
            participantQrPayload: pending.participantQrPayload!,
            containerQrPayload: pending.containerQrPayload!,
          );
      state = CafeteriaScanState(
        step: CafeteriaScanStep.finished,
        activity: CafeteriaScanActivity.success,
        participant: pending.participant,
        container: pending.container,
        returnPreview: pending.returnPreview,
        returnReceipt: receipt,
      );
    } catch (error) {
      final failure =
          _failure(error, 'No fue posible confirmar la devolución.');
      if (failure is NetworkFailure) {
        state = CafeteriaScanState(
          step: CafeteriaScanStep.review,
          activity: CafeteriaScanActivity.uncertain,
          participant: pending.participant,
          container: pending.container,
          returnPreview: pending.returnPreview,
          failure: failure,
          participantQrPayload: pending.participantQrPayload,
          containerQrPayload: pending.containerQrPayload,
        );
        return;
      }

      ResolvedContainerQr? refreshed = pending.container;
      if (failure is ConflictFailure) {
        try {
          refreshed = await ref
              .read(qrRepositoryProvider)
              .resolveContainerQr(pending.containerQrPayload!);
        } catch (_) {
          // Keep the original typed return conflict.
        }
      }
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.failure,
        participant: pending.participant,
        container: refreshed,
        returnPreview: pending.returnPreview,
        failure: failure,
      );
    }
  }

  Future<void> recoverUncertainReturn() async {
    if (state.activity != CafeteriaScanActivity.uncertain ||
        state.containerQrPayload == null ||
        state.participant == null) {
      return;
    }
    final pending = state;
    state = CafeteriaScanState(
      step: CafeteriaScanStep.review,
      activity: CafeteriaScanActivity.resolving,
      participant: pending.participant,
      container: pending.container,
      returnPreview: pending.returnPreview,
      participantQrPayload: pending.participantQrPayload,
      containerQrPayload: pending.containerQrPayload,
    );
    try {
      final refreshed = await ref
          .read(qrRepositoryProvider)
          .resolveContainerQr(pending.containerQrPayload!);
      if (refreshed.state == 'RETURNED' &&
          refreshed.activeCirculation == null) {
        state = CafeteriaScanState(
          step: CafeteriaScanStep.finished,
          activity: CafeteriaScanActivity.success,
          participant: pending.participant,
          container: refreshed,
          returnPreview: pending.returnPreview,
          recoveredFromState: true,
        );
        return;
      }

      final preview = await ref.read(returnRepositoryProvider).preview(
            participantQrPayload: pending.participantQrPayload!,
            containerQrPayload: pending.containerQrPayload!,
          );
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.ready,
        participant: pending.participant,
        container: refreshed,
        returnPreview: preview,
        participantQrPayload: pending.participantQrPayload,
        containerQrPayload: pending.containerQrPayload,
      );
    } catch (error) {
      state = CafeteriaScanState(
        step: CafeteriaScanStep.review,
        activity: CafeteriaScanActivity.uncertain,
        participant: pending.participant,
        container: pending.container,
        returnPreview: pending.returnPreview,
        failure: _failure(error, 'Aún no pudimos confirmar la devolución.'),
        participantQrPayload: pending.participantQrPayload,
        containerQrPayload: pending.containerQrPayload,
      );
    }
  }

  void retry() {
    if (state.step == CafeteriaScanStep.participant ||
        state.step == CafeteriaScanStep.container) {
      start();
    } else if (state.activity == CafeteriaScanActivity.failure) {
      reset();
    }
  }

  void reset() => state = const CafeteriaScanState();

  Failure _failure(Object error, String fallback) =>
      error is Failure ? error : ServerFailure(fallback);
}
