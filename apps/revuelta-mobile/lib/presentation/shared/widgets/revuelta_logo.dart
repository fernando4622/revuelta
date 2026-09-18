import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ReVuelta brand logo widget (Leaf + Circular circulation mark)
/// with title and optional subtitle ("El ciclo de tu contenedor en tus manos.").
class RevueltaLogo extends StatelessWidget {
  final double iconSize;
  final double titleSize;
  final bool showSubtitle;
  final Color? color;

  const RevueltaLogo({
    super.key,
    this.iconSize = 48,
    this.titleSize = 30,
    this.showSubtitle = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.forestGreen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Leaf icon container
        Container(
          width: iconSize + 16,
          height: iconSize + 16,
          decoration: BoxDecoration(
            color: AppColors.mintGreen.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.eco,
            size: iconSize,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ReVuelta',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          const Text(
            'El ciclo de tu contenedor\nen tus manos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}
