import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PilotDataBanner extends StatelessWidget {
  const PilotDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.science_outlined,
            size: 18,
            color: AppColors.warningOrange,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Datos de demostración del piloto.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
