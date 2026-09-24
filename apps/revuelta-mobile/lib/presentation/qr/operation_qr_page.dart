import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../application/qr/qr_providers.dart';
import '../../domain/failure/failure.dart';
import '../../domain/qr/operation_qr.dart';
import '../shared/theme/app_colors.dart';

class OperationQrPage extends ConsumerStatefulWidget {
  const OperationQrPage({super.key});

  @override
  ConsumerState<OperationQrPage> createState() => _OperationQrPageState();
}

class _OperationQrPageState extends ConsumerState<OperationQrPage> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(operationQrProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mi QR ReVuelta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '¿Qué vas a hacer?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Genera un código nuevo y muéstralo a Cafetería. También deberán escanear el QR del recipiente.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PurposeButton(
                    key: const Key('generate-delivery-qr'),
                    icon: Icons.restaurant_outlined,
                    label: 'Entrega',
                    onPressed: qrState.isLoading
                        ? null
                        : () => ref
                            .read(operationQrProvider.notifier)
                            .generate(OperationQrPurpose.delivery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PurposeButton(
                    key: const Key('generate-return-qr'),
                    icon: Icons.keyboard_return,
                    label: 'Devolución',
                    onPressed: qrState.isLoading
                        ? null
                        : () => ref
                            .read(operationQrProvider.notifier)
                            .generate(OperationQrPurpose.returnContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            qrState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => _QrFailure(
                message: error is Failure
                    ? _friendlyFailure(error)
                    : 'No pudimos generar el QR. Intenta de nuevo.',
              ),
              data: (qr) => qr == null
                  ? const _InitialQrCard()
                  : _ActiveQrCard(qr: qr, now: _now),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurposeButton extends StatelessWidget {
  const _PurposeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.forestGreen,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class _InitialQrCard extends StatelessWidget {
  const _InitialQrCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.qr_code_2, size: 68, color: AppColors.textHint),
            SizedBox(height: 12),
            Text(
              'Elige Entrega o Devolución para generar tu código temporal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveQrCard extends StatelessWidget {
  const _ActiveQrCard({required this.qr, required this.now});

  final OperationQr qr;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final expired = !now.isBefore(qr.expiresAt.toLocal());
    final purposeLabel =
        qr.purpose == OperationQrPurpose.delivery ? 'ENTREGA' : 'DEVOLUCIÓN';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: expired
                    ? AppColors.errorRed.withValues(alpha: .1)
                    : AppColors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                expired ? 'QR VENCIDO' : purposeLabel,
                style: TextStyle(
                  color: expired ? AppColors.errorRed : AppColors.darkGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (!expired)
              Semantics(
                label: 'Código QR temporal para $purposeLabel',
                child: QrImageView(
                  key: const Key('operation-qr-image'),
                  data: qr.payload,
                  version: QrVersions.auto,
                  size: 250,
                  backgroundColor: Colors.white,
                ),
              )
            else
              const Icon(Icons.timer_off_outlined,
                  size: 100, color: AppColors.errorRed),
            const SizedBox(height: 14),
            Text(
              expired
                  ? 'Genera un código nuevo para continuar.'
                  : 'Válido hasta ${DateFormat.Hms().format(qr.expiresAt.toLocal())}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cafetería debe escanear este QR y después el QR del recipiente. Mostrarlo no confirma ninguna operación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrFailure extends StatelessWidget {
  const _QrFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.errorRed.withValues(alpha: .08),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

String _friendlyFailure(Failure failure) => switch (failure.code) {
      'PARTICIPANT_ACCOUNT_NOT_LINKED' =>
        'Tu cuenta todavía no está vinculada a un perfil participante.',
      'PARTICIPANT_INACTIVE' =>
        'Tu perfil participante no está activo. Solicita ayuda a ReVuelta.',
      'NETWORK_ERROR' => 'Sin conexión. Revisa tu red e intenta de nuevo.',
      _ =>
        'No fue posible generar el QR. Intenta nuevamente o solicita ayuda a ReVuelta.',
    };
