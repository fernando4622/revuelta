import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/operations/role_experience_providers.dart';
import '../../domain/auth/user_session.dart';
import '../../domain/failure/failure.dart';
import '../scan/scan_page.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/logout_icon_button.dart';

class CafeteriaShell extends ConsumerStatefulWidget {
  const CafeteriaShell({super.key, required this.session});
  final UserSession session;

  @override
  ConsumerState<CafeteriaShell> createState() => _CafeteriaShellState();
}

class _CafeteriaShellState extends ConsumerState<CafeteriaShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      ScanPage(),
      _PendingWashesPage(),
      _RecentOperationsPage(),
      _CafeteriaHelpPage()
    ];
    return Scaffold(
      key: const Key('cafeteria-shell'),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.qr_code_scanner), label: 'Escanear'),
          NavigationDestination(
              icon: Icon(Icons.cleaning_services_outlined), label: 'Lavado'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Recientes'),
          NavigationDestination(icon: Icon(Icons.help_outline), label: 'Ayuda'),
        ],
      ),
    );
  }
}

class _PendingWashesPage extends ConsumerWidget {
  const _PendingWashesPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(pendingWashesProvider);
    final mutation = ref.watch(washControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Pendientes de lavado'),
          actions: const [LogoutIconButton()]),
      body: queue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _RoleError(
          message: _message(error, 'No pudimos cargar la cola de lavado.'),
          onRetry: () => ref.invalidate(pendingWashesProvider),
        ),
        data: (page) => page.items.isEmpty
            ? const _RoleEmpty(
                icon: Icons.cleaning_services_outlined,
                message: 'No hay recipientes pendientes de lavado.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(pendingWashesProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = page.items[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined,
                            color: AppColors.warningOrange),
                        title: Text(item.publicCode,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${item.stateLabel}\nRecibido: ${DateFormat('dd MMM, HH:mm').format(item.returnedAt.toLocal())}'),
                        isThreeLine: true,
                        trailing: FilledButton(
                          onPressed: mutation.isLoading
                              ? null
                              : () => _confirmWash(context, ref,
                                  item.containerId, item.publicCode),
                          child: const Text('Lavado'),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _confirmWash(
      BuildContext context, WidgetRef ref, String id, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar lavado'),
        content: Text(
            '¿El recipiente $code está limpio y listo para volver al ciclo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await ref.read(washControllerProvider.notifier).complete(id);
    if (!context.mounted) return;
    final state = ref.read(washControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '$code quedó disponible.'
          : _message(state.error, 'No fue posible confirmar el lavado.')),
    ));
  }
}

class _RecentOperationsPage extends ConsumerWidget {
  const _RecentOperationsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(recentOperatorOperationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Operaciones recientes'),
          actions: const [LogoutIconButton()]),
      body: activity.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _RoleError(
          message: _message(error, 'No pudimos cargar tus operaciones.'),
          onRetry: () => ref.invalidate(recentOperatorOperationsProvider),
        ),
        data: (page) => page.items.isEmpty
            ? const _RoleEmpty(
                icon: Icons.history,
                message: 'Aún no has registrado operaciones.')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(recentOperatorOperationsProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.items.length,
                  itemBuilder: (context, index) {
                    final item = page.items[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(_eventIcon(item.eventType),
                            color: AppColors.forestGreen),
                        title: Text(
                            '${_eventLabel(item.eventType)} · ${item.publicCode}'),
                        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm')
                            .format(item.occurredAt.toLocal())),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _CafeteriaHelpPage extends StatelessWidget {
  const _CafeteriaHelpPage();
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            title: const Text('Ayuda operativa'),
            actions: const [LogoutIconButton()]),
        body: ListView(padding: const EdgeInsets.all(20), children: const [
          _HelpStep(number: '1', text: 'Escanea el QR dinámico del cliente.'),
          _HelpStep(number: '2', text: 'Verifica si es entrega o devolución.'),
          _HelpStep(
              number: '3',
              text: 'Escanea siempre el QR estático del recipiente.'),
          _HelpStep(
              number: '4',
              text: 'Confirma únicamente cuando ambos códigos sean válidos.'),
        ]),
      );
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({required this.number, required this.text});
  final String number;
  final String text;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              child: Text(number)),
          title: Text(text),
        ),
      );
}

class _RoleEmpty extends StatelessWidget {
  const _RoleEmpty({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 58, color: AppColors.forestGreen),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ]));
}

class _RoleError extends StatelessWidget {
  const _RoleError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ]),
      ));
}

String _message(Object? error, String fallback) =>
    error is Failure ? error.message : fallback;
String _eventLabel(String type) => switch (type) {
      'DELIVERED' => 'Entrega',
      'RETURNED' => 'Devolución',
      'WASH_COMPLETED' => 'Lavado',
      _ => type,
    };
IconData _eventIcon(String type) => switch (type) {
      'DELIVERED' => Icons.outbox_outlined,
      'RETURNED' => Icons.assignment_return_outlined,
      'WASH_COMPLETED' => Icons.cleaning_services_outlined,
      _ => Icons.history,
    };
