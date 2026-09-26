import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/operations/role_experience_providers.dart';
import '../../domain/auth/user_session.dart';
import '../../domain/failure/failure.dart';
import '../../domain/operations/role_experience.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/container_card.dart';
import '../shared/widgets/logout_icon_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage(
      {super.key, required this.session, this.onScanTap, this.onMapTap});

  final UserSession session;
  final VoidCallback? onScanTap;
  final VoidCallback? onMapTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(myActiveCirculationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(myActiveCirculationsProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, ${session.username}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900)),
                        const Text('Aquí están tus recipientes activos.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const LogoutIconButton(color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 22),
              active.when(
                loading: () => const _LoadingState(),
                error: (error, _) => _ErrorState(
                  message: _failureMessage(error),
                  onRetry: () => ref.invalidate(myActiveCirculationsProvider),
                ),
                data: (page) => page.items.isEmpty
                    ? _EmptyState(onQrTap: onScanTap)
                    : _ActiveState(items: page.items, onQrTap: onScanTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveState extends StatelessWidget {
  const _ActiveState({required this.items, required this.onQrTap});

  final List<ParticipantCirculation> items;
  final VoidCallback? onQrTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM, HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
            items.length == 1
                ? '1 recipiente en uso'
                : '${items.length} recipientes en uso',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final item in items) ...[
          ContainerCard(code: item.publicCode, status: item.containerState),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              'Devuelve en Cafetería antes de ${formatter.format(item.dueAt.toLocal())}.',
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onQrTap,
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Generar QR para devolver'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              minimumSize: const Size.fromHeight(52)),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onQrTap});
  final VoidCallback? onQrTap;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.inventory_2_outlined,
              size: 72, color: AppColors.forestGreen),
          const SizedBox(height: 18),
          const Text('No tienes recipientes activos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Cuando pidas en Cafetería, genera tu QR de entrega.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: onQrTap,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Generar QR para pedir'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
          ),
        ],
      );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator()));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Icon(Icons.sync_problem,
                color: AppColors.warningOrange, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ]),
        ),
      );
}

String _failureMessage(Object error) => error is Failure
    ? error.message
    : 'No pudimos cargar tu información. Intenta nuevamente.';
