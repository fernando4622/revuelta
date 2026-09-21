import 'package:flutter/material.dart';

import '../../domain/auth/user_session.dart';
import '../scan/scan_page.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/logout_icon_button.dart';

class CafeteriaShell extends StatefulWidget {
  const CafeteriaShell({
    super.key,
    required this.session,
  });

  final UserSession session;

  @override
  State<CafeteriaShell> createState() => _CafeteriaShellState();
}

class _CafeteriaShellState extends State<CafeteriaShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ScanPage(),
      const _UnavailableCafeteriaPage(
        title: 'Pendientes de lavado',
        icon: Icons.cleaning_services_outlined,
        message:
            'Esta cola se habilitará cuando exista la consulta operativa en el backend.',
      ),
      const _UnavailableCafeteriaPage(
        title: 'Operaciones recientes',
        icon: Icons.history,
        message:
            'El historial aparecerá cuando el API exponga operaciones de esta cafetería.',
      ),
      const _CafeteriaHelpPage(),
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

class _UnavailableCafeteriaPage extends StatelessWidget {
  const _UnavailableCafeteriaPage({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: const [LogoutIconButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 58, color: AppColors.forestGreen),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CafeteriaHelpPage extends StatelessWidget {
  const _CafeteriaHelpPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ayuda operativa'),
        actions: const [LogoutIconButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _HelpStep(number: '1', text: 'Escanea el QR dinámico del cliente.'),
          _HelpStep(
              number: '2',
              text: 'Verifica la operación solicitada: entrega o devolución.'),
          _HelpStep(
              number: '3',
              text: 'Escanea siempre el QR estático del recipiente.'),
          _HelpStep(
              number: '4',
              text:
                  'Verifica que el estado permita la operación antes de confirmarla.'),
        ],
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: Colors.white,
          child: Text(number),
        ),
        title: Text(text),
      ),
    );
  }
}
