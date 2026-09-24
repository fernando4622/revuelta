import 'package:flutter/material.dart';

import '../../domain/auth/user_session.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/logout_icon_button.dart';

class RevueltaOperationsShell extends StatefulWidget {
  const RevueltaOperationsShell({
    super.key,
    required this.session,
  });

  final UserSession session;

  @override
  State<RevueltaOperationsShell> createState() =>
      _RevueltaOperationsShellState();
}

class _RevueltaOperationsShellState extends State<RevueltaOperationsShell> {
  static const _destinations = [
    _OperationsDestination('Resumen', Icons.dashboard_outlined),
    _OperationsDestination('Participantes', Icons.groups_outlined),
    _OperationsDestination('Recipientes', Icons.inventory_2_outlined),
    _OperationsDestination('Circulaciones', Icons.sync_alt),
    _OperationsDestination('Incidencias', Icons.report_problem_outlined),
    _OperationsDestination('Auditoría', Icons.fact_check_outlined),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_selectedIndex];

    return Scaffold(
      key: const Key('revuelta-operations-shell'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Operación ReVuelta'),
        actions: const [LogoutIconButton()],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
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
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _OperationsPlaceholder(destination: destination),
    );
  }
}

class _OperationsDestination {
  const _OperationsDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _OperationsPlaceholder extends StatelessWidget {
  const _OperationsPlaceholder({required this.destination});

  final _OperationsDestination destination;

  @override
  Widget build(BuildContext context) {
    final title = destination.label == 'Resumen'
        ? 'Resumen del piloto'
        : destination.label;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, size: 64, color: AppColors.forestGreen),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Módulo pendiente durante esta etapa del piloto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
