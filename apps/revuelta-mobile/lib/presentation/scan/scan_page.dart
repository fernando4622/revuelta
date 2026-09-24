import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

import '../../application/qr/qr_providers.dart';
import '../../domain/failure/failure.dart';
import '../../domain/qr/operation_qr.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/cycle_pulse_indicator.dart';
import '../shared/widgets/logout_icon_button.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  int _scannerRevision = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cafeteriaScanProvider);
    final isCameraVisible = state.activity == CafeteriaScanActivity.scanning;
    return Scaffold(
      backgroundColor: const Color(0xFF1E272E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Escanear ReVuelta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: const [LogoutIconButton(color: Colors.white)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isCameraVisible
                    ? _CameraView(
                        key: ValueKey(_scannerRevision),
                        instruction: state.step == CafeteriaScanStep.participant
                            ? '1 de 2 · Escanea el QR del cliente'
                            : '2 de 2 · Escanea el QR del recipiente',
                        onPayload: (payload) => ref
                            .read(cafeteriaScanProvider.notifier)
                            .acceptPayload(payload),
                        onRetry: () => setState(() => _scannerRevision++),
                      )
                    : _ScannerStatus(state: state),
              ),
            ),
            _BottomPanel(state: state),
          ],
        ),
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView({
    super.key,
    required this.instruction,
    required this.onPayload,
    required this.onRetry,
  });

  final String instruction;
  final ValueChanged<String> onPayload;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: MobileScanner(
              onDetect: (capture) {
                final payload = capture.barcodes
                    .map((barcode) => barcode.rawValue)
                    .whereType<String>()
                    .firstOrNull;
                if (payload != null) onPayload(payload);
              },
              errorBuilder: (context, error, child) => _CameraFailure(
                message: error.errorCode ==
                        MobileScannerErrorCode.permissionDenied
                    ? 'Necesitamos permiso de cámara para escanear ambos QR. Habilítalo en los ajustes del dispositivo.'
                    : 'No pudimos iniciar la cámara. Revisa que esté disponible.',
                onRetry: onRetry,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraFailure extends StatelessWidget {
  const _CameraFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1E272E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  size: 58, color: AppColors.warningOrange),
              const SizedBox(height: 14),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Reintentar cámara'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerStatus extends StatelessWidget {
  const _ScannerStatus({required this.state});

  final CafeteriaScanState state;

  @override
  Widget build(BuildContext context) {
    if (state.activity == CafeteriaScanActivity.resolving ||
        state.activity == CafeteriaScanActivity.previewing ||
        state.activity == CafeteriaScanActivity.submitting) {
      final message = switch (state.activity) {
        CafeteriaScanActivity.previewing => 'Preparando confirmación…',
        CafeteriaScanActivity.submitting => 'Confirmando entrega…',
        _ => 'Validando con ReVuelta…',
      };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
    if (state.step == CafeteriaScanStep.review ||
        state.step == CafeteriaScanStep.finished) {
      return const Center(
        child:
            Icon(Icons.check_circle, size: 112, color: AppColors.primaryGreen),
      );
    }
    return const Center(
      child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.white30),
    );
  }
}

class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({required this.state});

  final CafeteriaScanState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: switch ((state.step, state.activity)) {
        (_, CafeteriaScanActivity.uncertain) => _UncertainPanel(
            failure: state.failure,
            onRecover: () => ref
                .read(cafeteriaScanProvider.notifier)
                .recoverUncertainDelivery(),
            onReset: () => ref.read(cafeteriaScanProvider.notifier).reset(),
          ),
        (CafeteriaScanStep.finished, CafeteriaScanActivity.success) =>
          _DeliverySuccessPanel(
            state: state,
            onReset: () => ref.read(cafeteriaScanProvider.notifier).reset(),
          ),
        (_, CafeteriaScanActivity.failure) => _FailurePanel(
            failure: state.failure,
            onRetry: () => ref.read(cafeteriaScanProvider.notifier).retry(),
            onReset: () => ref.read(cafeteriaScanProvider.notifier).reset(),
          ),
        (CafeteriaScanStep.review, _) => _ReviewPanel(
            state: state,
            onConfirm: () =>
                ref.read(cafeteriaScanProvider.notifier).confirmDelivery(),
            onReset: () => ref.read(cafeteriaScanProvider.notifier).reset(),
          ),
        (CafeteriaScanStep.container, _) =>
          _ParticipantResolvedPanel(state: state),
        _ => _StartPanel(
            onStart: () => ref.read(cafeteriaScanProvider.notifier).start(),
          ),
      },
    );
  }
}

class _StartPanel extends StatelessWidget {
  const _StartPanel({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Entrega y devolución con doble validación',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Siempre se escanea primero el QR dinámico del cliente y después el QR estático del recipiente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          key: const Key('start-dual-qr-scan'),
          onPressed: onStart,
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Abrir cámara'),
        ),
      ],
    );
  }
}

class _ParticipantResolvedPanel extends StatelessWidget {
  const _ParticipantResolvedPanel({required this.state});

  final CafeteriaScanState state;

  @override
  Widget build(BuildContext context) {
    final participant = state.participant!;
    final operation = participant.purpose == OperationQrPurpose.delivery
        ? 'Entrega'
        : 'Devolución';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen),
            SizedBox(width: 8),
            Text('QR del cliente validado',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Operación solicitada: $operation'),
        const SizedBox(height: 4),
        Text(
          'Referencia: ${_shortRef(participant.participantRef)}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ahora escanea el recipiente. No es posible continuar sin el segundo QR.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    required this.state,
    required this.onConfirm,
    required this.onReset,
  });

  final CafeteriaScanState state;
  final VoidCallback onConfirm;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final container = state.container!;
    final isDelivery =
        state.participant!.purpose == OperationQrPurpose.delivery;
    final preview = state.preview;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CyclePulseIndicator(state: container.state, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(container.displayCode,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(container.stateLabel,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Cliente: ${_shortRef(state.participant!.participantRef)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: state.isPairCompatible
                ? AppColors.lightGreen
                : AppColors.warningOrange.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            state.isPairCompatible
                ? isDelivery
                    ? 'Ambos QR son válidos. Revisa la política antes de confirmar.'
                    : 'Ambos QR son válidos. La devolución se habilitará en F6.'
                : 'Ambos QR fueron leídos, pero el estado actual del recipiente no permite esta operación.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        if (preview != null) ...[
          const SizedBox(height: 14),
          Text(preview.policy.name,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Plazo: ${preview.policy.durationHours} h · versión ${preview.policy.version}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Devolución estimada: ${_dateTime(preview.estimatedDueAt)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'La fecha exacta la confirma el servidor al completar la entrega.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
        const SizedBox(height: 14),
        if (isDelivery && state.isPairCompatible) ...[
          ElevatedButton.icon(
            key: const Key('confirm-delivery'),
            onPressed: state.canConfirmDelivery ? onConfirm : null,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirmar entrega'),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(
          key: const Key('cancel-delivery'),
          onPressed: onReset,
          child: const Text('Cancelar y borrar escaneo'),
        ),
      ],
    );
  }
}

class _UncertainPanel extends StatelessWidget {
  const _UncertainPanel({
    required this.failure,
    required this.onRecover,
    required this.onReset,
  });

  final Failure? failure;
  final VoidCallback onRecover;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Resultado por confirmar',
            style: TextStyle(
                color: AppColors.warningOrange,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        const SizedBox(height: 8),
        const Text(
          'Se perdió la conexión después de enviar la entrega. No asumimos éxito ni repetimos la operación automáticamente.',
        ),
        if (failure?.message.isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(failure!.message,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 14),
        ElevatedButton(
          key: const Key('recover-delivery'),
          onPressed: onRecover,
          child: const Text('Consultar estado actual'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
            onPressed: onReset, child: const Text('Cerrar operación')),
      ],
    );
  }
}

class _DeliverySuccessPanel extends StatelessWidget {
  const _DeliverySuccessPanel({required this.state, required this.onReset});

  final CafeteriaScanState state;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final receipt = state.receipt;
    final active = state.container?.activeCirculation;
    final dueAt = receipt?.dueAt ?? active?.dueAt;
    final circulationRef = receipt?.circulationId ?? active?.circulationRef;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text('Entrega confirmada',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
            'Recipiente: ${receipt?.container.publicCode ?? state.container?.displayCode}'),
        if (receipt != null)
          Text('Entregado: ${_dateTime(receipt.deliveredAt)}'),
        if (dueAt != null) Text('Devolver antes de: ${_dateTime(dueAt)}'),
        if (receipt != null)
          Text('Política: ${receipt.policy.name} · v${receipt.policy.version}'),
        if (circulationRef != null)
          Text('Circulación: ${_shortRef(circulationRef)}',
              style: const TextStyle(color: AppColors.textSecondary)),
        if (state.recoveredFromState) ...[
          const SizedBox(height: 8),
          const Text(
            'Resultado recuperado consultando el estado actual; no se reenvió la entrega.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
        const SizedBox(height: 14),
        ElevatedButton(
          key: const Key('finish-delivery'),
          onPressed: onReset,
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}

class _FailurePanel extends StatelessWidget {
  const _FailurePanel({
    required this.failure,
    required this.onRetry,
    required this.onReset,
  });

  final Failure? failure;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('No pudimos validar este QR',
            style: TextStyle(
                color: AppColors.errorRed, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(_scannerFailureMessage(failure)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: onRetry, child: const Text('Reintentar'))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton(
                    onPressed: onReset, child: const Text('Reiniciar'))),
          ],
        ),
      ],
    );
  }
}

String _scannerFailureMessage(Failure? failure) => switch (failure?.code) {
      'QR_EXPIRED' => 'El QR del cliente venció. Pídele que genere uno nuevo.',
      'QR_ALREADY_USED' => 'Este QR ya fue utilizado en otra operación.',
      'QR_PURPOSE_MISMATCH' =>
        'Este QR fue generado para otra operación. Solicita uno de entrega.',
      'QR_TAMPERED' ||
      'INVALID_QR' ||
      'UNSUPPORTED_QR_VERSION' =>
        'El código no es un QR ReVuelta válido.',
      'CONTAINER_QR_REVOKED' =>
        'El QR del recipiente fue reemplazado y ya no es vigente.',
      'INACTIVE_CONTAINER' => 'El recipiente no está activo para operar.',
      'PARTICIPANT_INACTIVE' => 'El cliente no está habilitado para operar.',
      'CONTAINER_NOT_AVAILABLE' ||
      'ACTIVE_CIRCULATION_EXISTS' =>
        'El recipiente ya no está disponible. Se actualizó su estado actual.',
      'POLICY_NOT_FOUND' =>
        'No hay una política de devolución activa. Contacta a ReVuelta.',
      'NETWORK_ERROR' => 'Sin conexión. Revisa la red e intenta otra vez.',
      _ => failure?.message ?? 'Ocurrió un error inesperado.',
    };

String _shortRef(String value) =>
    value.length <= 8 ? value : value.substring(0, 8);

String _dateTime(DateTime value) =>
    DateFormat('dd/MM/yyyy · HH:mm').format(value.toLocal());
