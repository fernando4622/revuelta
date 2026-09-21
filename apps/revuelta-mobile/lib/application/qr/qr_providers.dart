import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/qr/api_qr_repository.dart';
import '../../domain/failure/failure.dart';
import '../../domain/qr/operation_qr.dart';
import '../../domain/qr/resolved_container_qr.dart';
import '../auth/auth_notifier.dart';
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

enum CafeteriaScanStep { participant, container, complete }

enum CafeteriaScanActivity { idle, scanning, resolving, failure }

class CafeteriaScanState {
  const CafeteriaScanState({
    this.step = CafeteriaScanStep.participant,
    this.activity = CafeteriaScanActivity.idle,
    this.participant,
    this.container,
    this.failure,
  });

  final CafeteriaScanStep step;
  final CafeteriaScanActivity activity;
  final ResolvedOperationQr? participant;
  final ResolvedContainerQr? container;
  final Failure? failure;

  bool get isPairCompatible {
    final requiredAction = switch (participant?.purpose) {
      OperationQrPurpose.delivery => 'DELIVER',
      OperationQrPurpose.returnContainer => 'RETURN',
      null => null,
    };
    return requiredAction != null &&
        container?.allowedActions.contains(requiredAction) == true;
  }

  CafeteriaScanState copyWith({
    CafeteriaScanStep? step,
    CafeteriaScanActivity? activity,
    ResolvedOperationQr? participant,
    ResolvedContainerQr? container,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CafeteriaScanState(
      step: step ?? this.step,
      activity: activity ?? this.activity,
      participant: participant ?? this.participant,
      container: container ?? this.container,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

final cafeteriaScanProvider =
    AutoDisposeNotifierProvider<CafeteriaScanController, CafeteriaScanState>(
  CafeteriaScanController.new,
);

class CafeteriaScanController extends AutoDisposeNotifier<CafeteriaScanState> {
  @override
  CafeteriaScanState build() => const CafeteriaScanState();

  void start() {
    if (state.activity == CafeteriaScanActivity.resolving) return;
    state = state.copyWith(
      activity: CafeteriaScanActivity.scanning,
      clearFailure: true,
    );
  }

  Future<void> acceptPayload(String payload) async {
    if (payload.trim().isEmpty ||
        state.activity != CafeteriaScanActivity.scanning ||
        state.step == CafeteriaScanStep.complete) {
      return;
    }

    final resolvingStep = state.step;
    state = state.copyWith(
      activity: CafeteriaScanActivity.resolving,
      clearFailure: true,
    );

    try {
      final repository = ref.read(qrRepositoryProvider);
      if (resolvingStep == CafeteriaScanStep.participant) {
        final participant = await repository.resolveOperationQr(payload);
        state = state.copyWith(
          step: CafeteriaScanStep.container,
          activity: CafeteriaScanActivity.scanning,
          participant: participant,
          clearFailure: true,
        );
      } else {
        final container = await repository.resolveContainerQr(payload);
        state = state.copyWith(
          step: CafeteriaScanStep.complete,
          activity: CafeteriaScanActivity.idle,
          container: container,
          clearFailure: true,
        );
      }
    } catch (error) {
      state = state.copyWith(
        activity: CafeteriaScanActivity.failure,
        failure: error is Failure
            ? error
            : const ServerFailure('No fue posible validar el QR.'),
      );
    }
  }

  void retry() => start();

  void reset() => state = const CafeteriaScanState();
}
