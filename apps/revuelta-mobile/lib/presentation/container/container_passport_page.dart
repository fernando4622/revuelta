import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/cycle_pulse_indicator.dart';

/// Screen representing "Envase como Objeto Digital" (Digital Container Passport).
/// Displays cycle completion gauge, traceability timeline, and technical metadata.
class ContainerPassportPage extends StatelessWidget {
  final String containerId;
  final String code;
  final String status;
  final int completedCycles;
  final String? type;

  const ContainerPassportPage({
    super.key,
    required this.containerId,
    required this.code,
    required this.status,
    this.completedCycles = 27,
    this.type = 'Vaso 500 ml',
  });

  String get _displayCode {
    if (code.length > 6) {
      return 'RV \u2022 ${code.substring(code.length - 6).toUpperCase()}';
    }
    return 'RV \u2022 ${code.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container Graphic & Cycle Gauge
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular gauge
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: (completedCycles % 100) / 100.0,
                      strokeWidth: 6,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                  // Center Content (Cup icon & Cycle Count)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_cafe_outlined,
                        size: 40,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCycles',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'ciclos completados',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Container current status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CyclePulseIndicator(state: status, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type ?? 'Contenedor Reutilizable',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Estado actual: $status',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Traceability Timeline (Trazabilidad del envase)
            const Text(
              'Historial del Ciclo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _TimelineItem(
                      title: 'Fabricado',
                      date: '10.02.2024',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Usado en circulación',
                      date: '12.02.2024',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Lavado e higienizado',
                      date: '14.02.2024',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Usado en circulación',
                      date: '15.02.2024',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Contigo',
                      date: 'Actualmente',
                      isCompleted: true,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section: Technical Specifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Material: Polipropileno (PP)',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Vida útil: ~200 ciclos',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String date;
  final bool isCompleted;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.date,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.primaryGreen : AppColors.cardBorder,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? AppColors.primaryGreen.withOpacity(0.5) : AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
