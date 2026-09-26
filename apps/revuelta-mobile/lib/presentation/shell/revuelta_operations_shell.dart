import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/operations/role_experience_providers.dart';
import '../../domain/auth/user_session.dart';
import '../../domain/failure/failure.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/logout_icon_button.dart';

class RevueltaOperationsShell extends StatefulWidget {
  const RevueltaOperationsShell({super.key, required this.session});
  final UserSession session;

  @override
  State<RevueltaOperationsShell> createState() =>
      _RevueltaOperationsShellState();
}

class _RevueltaOperationsShellState extends State<RevueltaOperationsShell> {
  static const _destinations = [
    _Destination('Resumen', Icons.dashboard_outlined),
    _Destination('Participantes', Icons.groups_outlined),
    _Destination('Recipientes', Icons.inventory_2_outlined),
    _Destination('Circulaciones', Icons.sync_alt),
    _Destination('Incidencias', Icons.report_problem_outlined),
    _Destination('Auditoría', Icons.fact_check_outlined),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      _SummaryPage(),
      _ParticipantsPage(),
      _ContainersPage(),
      _CirculationsPage(),
      _IncidentsPage(),
      _AuditPage(),
    ];
    return Scaffold(
      key: const Key('revuelta-operations-shell'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(_destinations[_selectedIndex].label),
          actions: const [LogoutIconButton()]),
      drawer: Drawer(
        child: SafeArea(
          child: Column(children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.eco_outlined)),
              title: Text(widget.session.username),
              subtitle: Text(widget.session.role.displayName),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final item = _destinations[index];
                  return ListTile(
                    selected: index == _selectedIndex,
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _SummaryPage extends ConsumerWidget {
  const _SummaryPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(operationsSummaryProvider);
    return summary.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
          message: _message(error, 'No pudimos cargar el resumen.'),
          onRetry: () => ref.invalidate(operationsSummaryProvider)),
      data: (data) => RefreshIndicator(
        onRefresh: () => ref.refresh(operationsSummaryProvider.future),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
          childAspectRatio: 1.05,
          children: [
            _MetricCard(
                'Total', data.totalContainers, Icons.inventory_2_outlined),
            _MetricCard(
                'Disponibles', data.available, Icons.check_circle_outline),
            _MetricCard('En uso', data.inUse, Icons.sync),
            _MetricCard(
                'Por lavar', data.returned, Icons.cleaning_services_outlined),
            _MetricCard('Registrados', data.registered, Icons.app_registration),
            _MetricCard('Circulaciones activas', data.activeCirculations,
                Icons.people_alt_outlined),
            _MetricCard('Dañados', data.damaged, Icons.build_outlined),
            _MetricCard('Retirados o perdidos', data.retired + data.lost,
                Icons.block_outlined),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon);
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.forestGreen),
            const Spacer(),
            Text('$value',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ]),
        ),
      );
}

class _ParticipantsPage extends ConsumerWidget {
  const _ParticipantsPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(participantsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
                message: _message(error, 'No pudimos cargar participantes.'),
                onRetry: () => ref.invalidate(participantsProvider)),
            data: (page) => page.items.isEmpty
                ? const _EmptyView(
                    icon: Icons.groups_outlined,
                    message: 'No hay participantes registrados.')
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(participantsProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: page.items.length,
                      itemBuilder: (context, index) {
                        final item = page.items[index];
                        return Card(
                            child: ListTile(
                          leading: Icon(item.active
                              ? Icons.person_outline
                              : Icons.person_off_outlined),
                          title: Text(_short(item.participantRef)),
                          subtitle: Text(
                              'Alta: ${DateFormat('dd MMM yyyy').format(item.createdAt.toLocal())}'),
                          trailing: Text(item.active ? 'Activo' : 'Inactivo'),
                        ));
                      },
                    ),
                  ),
          );
}

class _ContainersPage extends ConsumerStatefulWidget {
  const _ContainersPage();
  @override
  ConsumerState<_ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends ConsumerState<_ContainersPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(containersProvider(_query));
    final mutation = ref.watch(containerMutationControllerProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
              child: TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Buscar por código'),
            onSubmitted: (value) => setState(() => _query = value.trim()),
          )),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Registrar recipiente',
            onPressed: mutation.isLoading ? null : () => _register(context),
            icon: const Icon(Icons.add),
          ),
        ]),
      ),
      Expanded(
          child: inventory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
            message: _message(error, 'No pudimos cargar los recipientes.'),
            onRetry: () => ref.invalidate(containersProvider(_query))),
        data: (page) => page.items.isEmpty
            ? const _EmptyView(
                icon: Icons.inventory_2_outlined,
                message: 'No hay recipientes que coincidan.')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: page.items.length,
                itemBuilder: (context, index) {
                  final item = page.items[index];
                  return Card(
                      child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.forestGreen),
                    title: Text(item.code,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(item.status),
                    trailing: item.status == 'REGISTERED'
                        ? TextButton(
                            onPressed: mutation.isLoading
                                ? null
                                : () async {
                                    final ok = await ref
                                        .read(
                                            containerMutationControllerProvider
                                                .notifier)
                                        .activate(item.id);
                                    if (!context.mounted) return;
                                    _snack(
                                        context,
                                        ok
                                            ? '${item.code} quedó disponible.'
                                            : _message(
                                                ref
                                                    .read(
                                                        containerMutationControllerProvider)
                                                    .error,
                                                'No fue posible activar.'));
                                  },
                            child: const Text('Activar'),
                          )
                        : null,
                  ));
                },
              ),
      )),
    ]);
  }

  Future<void> _register(BuildContext context) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar recipiente'),
        content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Código público')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Registrar')),
        ],
      ),
    );
    controller.dispose();
    if (code == null || code.isEmpty || !context.mounted) return;
    final ok = await ref
        .read(containerMutationControllerProvider.notifier)
        .register(code);
    if (!context.mounted) return;
    _snack(
        context,
        ok
            ? '$code fue registrado.'
            : _message(ref.read(containerMutationControllerProvider).error,
                'No fue posible registrar.'));
  }
}

class _CirculationsPage extends ConsumerWidget {
  const _CirculationsPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(operationsCirculationsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
                message: _message(error, 'No pudimos cargar circulaciones.'),
                onRetry: () => ref.invalidate(operationsCirculationsProvider)),
            data: (page) => page.items.isEmpty
                ? const _EmptyView(
                    icon: Icons.sync_alt,
                    message: 'No hay circulaciones registradas.')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: page.items.length,
                    itemBuilder: (context, index) {
                      final item = page.items[index];
                      return Card(
                          child: ListTile(
                        leading: Icon(
                            item.status == 'ACTIVE' ? Icons.sync : Icons.check),
                        title: Text(item.publicCode),
                        subtitle: Text(
                            '${item.status} · Participante ${_short(item.participantRef)}\nEntrega: ${DateFormat('dd MMM, HH:mm').format(item.deliveredAt.toLocal())}'),
                        isThreeLine: true,
                      ));
                    },
                  ),
          );
}

class _AuditPage extends ConsumerWidget {
  const _AuditPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(operationsEventsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
                message: _message(error, 'No pudimos cargar la auditoría.'),
                onRetry: () => ref.invalidate(operationsEventsProvider)),
            data: (page) => page.items.isEmpty
                ? const _EmptyView(
                    icon: Icons.fact_check_outlined,
                    message: 'No hay eventos registrados.')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: page.items.length,
                    itemBuilder: (context, index) {
                      final event = page.items[index];
                      return Card(
                          child: ExpansionTile(
                        title: Text('${event.eventType} · ${event.publicCode}'),
                        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm')
                            .format(event.occurredAt.toLocal())),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  'Actor: ${_short(event.actorId)}\nEstado: ${event.previousStatus ?? '—'} → ${event.newStatus}\nTraza: ${event.traceId}'))
                        ],
                      ));
                    },
                  ),
          );
}

class _IncidentsPage extends StatelessWidget {
  const _IncidentsPage();
  @override
  Widget build(BuildContext context) => const _EmptyView(
        icon: Icons.report_problem_outlined,
        message:
            'Las incidencias estarán disponibles cuando se aprueben sus reglas de evidencia y resolución.',
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 58, color: AppColors.forestGreen),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center)
        ]),
      ));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar'))
        ]),
      ));
}

String _message(Object? error, String fallback) =>
    error is Failure ? error.message : fallback;
String _short(String value) =>
    value.length <= 12 ? value : '${value.substring(0, 8)}…';
void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
