import 'package:flutter/material.dart';

/// Canonical ReVuelta brand asset approved by the product specification.
class RevueltaLogo extends StatelessWidget {
  final double width;

  const RevueltaLogo({
    super.key,
    this.width = 210,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'resources/logo.jpeg',
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'ReVuelta, cada vuelta cuenta',
      ),
    );
  }
}
