import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'cycle_pulse_indicator.dart';

/// Reusable container card matching the ReVuelta design.
///
/// Displays a container with its code, status indicator,
/// optional type description and cycle count.
class ContainerCard extends StatelessWidget {
  final String code;
  final String status;
  final String? type;
  final int? cycleCount;
  final VoidCallback? onTap;

  const ContainerCard({
    super.key,
    required this.code,
    required this.status,
    this.type,
    this.cycleCount,
    this.onTap,
  });

  String get _displayCode {
    if (code.length > 6) {
      return 'RV \u2022 ${code.substring(code.length - 6).toUpperCase()}';
    }
    return 'RV \u2022 ${code.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cycle indicator
              CyclePulseIndicator(state: status, size: 44),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayCode,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (type != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        type!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    _StatusBadge(status: status),
                  ],
                ),
              ),

              // Cycle count
              if (cycleCount != null) ...[
                Column(
                  children: [
                    Text(
                      '$cycleCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const Text(
                      'ciclos',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // Chevron
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.statusAvailable;
      case 'IN_USE':
      case 'ASSIGNED':
        return AppColors.statusInUse;
      case 'RETURNED':
        return AppColors.statusReturned;
      case 'DAMAGED':
        return AppColors.statusDamaged;
      case 'LOST':
        return AppColors.statusLost;
      case 'RETIRED':
        return AppColors.statusRetired;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Disponible';
      case 'IN_USE':
        return 'En uso';
      case 'ASSIGNED':
        return 'Asignado';
      case 'RETURNED':
        return 'Devuelto';
      case 'DAMAGED':
        return 'Dañado';
      case 'LOST':
        return 'Perdido';
      case 'RETIRED':
        return 'Retirado';
      case 'REGISTERED':
        return 'Registrado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
