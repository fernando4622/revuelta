import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../delivery/delivery_page.dart';
import '../return_flow/return_page.dart';
import '../return_flow/student_return_flow_page.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/container_card.dart';
import '../container/container_passport_page.dart';

/// Screen representing "Inicio" (Mockup Screen 1).
/// Features user greeting ("Hola, Valeria"), current active container status card with arc gauge,
/// next action banner ("Devuelve tu contenedor"), prominent QR scan CTA,
/// and adaptive switcher to preview different modes.
class HomePage extends ConsumerStatefulWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onMapTap;

  const HomePage({
    super.key,
    this.onScanTap,
    this.onMapTap,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Demonstration toggle: 0: Sin envases, 1: 1 envase (Valeria Default), 2: Varios envases
  int _stateDemoIndex = 1;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authNotifierProvider).value;
    final username = session?.username ?? 'Valeria';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Greeting Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, $username',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tu contenedor hace la diferencia.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Context demo switcher & Logout
                  Row(
                    children: [
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.tune, color: AppColors.textSecondary, size: 20),
                        tooltip: 'Cambiar modo adaptativo',
                        onSelected: (val) => setState(() => _stateDemoIndex = val),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 0, child: Text('Modo: 0 envases')),
                          PopupMenuItem(value: 1, child: Text('Modo: 1 envase (Valeria)')),
                          PopupMenuItem(value: 2, child: Text('Modo: Varios envases')),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
                        onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_stateDemoIndex == 1) ...[
                      _buildValeriaActiveContainerState(),
                    ] else if (_stateDemoIndex == 0) ...[
                      _buildZeroContainersState(),
                    ] else ...[
                      _buildMultipleContainersState(),
                    ],

                    const SizedBox(height: 24),

                    // Quick Operational Actions Row
                    const Text(
                      'Acciones de Operación',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.output,
                            label: 'Entregar',
                            color: AppColors.forestGreen,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DeliveryPage()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.input,
                            label: 'Devolver',
                            color: AppColors.darkGreen,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ReturnPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// State 1: Valeria with 1 Active Container (Mockup Screen 1)
  Widget _buildValeriaActiveContainerState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Bento / Lunchbox Card with Arc Gauge
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentReturnFlowPage(containerCode: '#RV-0247'),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  // Container Graphic & Arc Ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mintGreen.withOpacity(0.4),
                          border: Border.all(color: AppColors.forestGreen, width: 4),
                        ),
                      ),
                      const Icon(
                        Icons.lunch_dining,
                        size: 56,
                        color: AppColors.forestGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'En uso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Hace 42 min \u2022 Ventana puntual activa',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Próximo paso Card
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentReturnFlowPage(containerCode: '#RV-0247'),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximo paso',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Devuelve tu contenedor para que vuelva al ciclo.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Main CTA: Escanear QR
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner, size: 22),
          label: const Text('Escanear QR para devolver'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentReturnFlowPage(containerCode: '#RV-0247'),
              ),
            );
          },
        ),
      ],
    );
  }

  /// State 0: 0 Containers
  Widget _buildZeroContainersState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mintGreen.withOpacity(0.5),
          ),
          child: const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.forestGreen),
        ),
        const SizedBox(height: 20),
        const Text(
          'No tienes nada por devolver.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '\u00A1Pide tu próximo almuerzo en ReVuelta!',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Escanear envase'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: widget.onScanTap,
        ),
      ],
    );
  }

  /// State 2: Multiple Containers
  Widget _buildMultipleContainersState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContainerCard(
          code: 'RV-0247',
          status: 'IN_USE',
          type: 'Bento Lunch',
          cycleCount: 28,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentReturnFlowPage(containerCode: '#RV-0247'),
              ),
            );
          },
        ),
        ContainerCard(
          code: 'RV-0183',
          status: 'IN_USE',
          type: 'Vaso 500 ml',
          cycleCount: 14,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ContainerPassportPage(
                  containerId: 'RV-0183',
                  code: 'RV-0183',
                  status: 'IN_USE',
                  completedCycles: 14,
                  type: 'Vaso 500 ml',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
