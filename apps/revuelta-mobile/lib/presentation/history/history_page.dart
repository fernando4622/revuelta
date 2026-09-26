import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/operations/role_experience_providers.dart';
import '../../domain/failure/failure.dart';
import '../shared/theme/app_colors.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(myCirculationsProvider(_status));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                    label: const Text('Todos'),
                    selected: _status == null,
                    onSelected: (_) => setState(() => _status = null)),
                ChoiceChip(
                    label: const Text('En uso'),
                    selected: _status == 'ACTIVE',
                    onSelected: (_) => setState(() => _status = 'ACTIVE')),
                ChoiceChip(
                    label: const Text('Devueltos'),
                    selected: _status == 'COMPLETED',
                    onSelected: (_) => setState(() => _status = 'COMPLETED')),
              ],
            ),
          ),
          Expanded(
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _HistoryError(
                message: error is Failure
                    ? error.message
                    : 'No pudimos cargar tu historial.',
                onRetry: () => ref.invalidate(myCirculationsProvider(_status)),
              ),
              data: (page) => page.items.isEmpty
                  ? const _EmptyHistory()
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(myCirculationsProvider(_status).future),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: page.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = page.items[index];
                          final when = item.returnedAt ?? item.deliveredAt;
                          final label =
                              item.status == 'ACTIVE' ? 'En uso' : 'Devuelto';
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                item.status == 'ACTIVE'
                                    ? Icons.sync
                                    : Icons.check_circle_outline,
                                color: AppColors.forestGreen,
                              ),
                              title: Text(item.publicCode,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                  '$label · ${DateFormat('dd MMM yyyy, HH:mm').format(when.toLocal())}'),
                              trailing: item.punctuality == null
                                  ? null
                                  : Text(item.punctuality == 'ON_TIME'
                                      ? 'A tiempo'
                                      : 'Tarde'),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.history, size: 58, color: AppColors.forestGreen),
            SizedBox(height: 12),
            Text('Aún no hay movimientos en esta vista.',
                textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});
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
        ),
      );
}
