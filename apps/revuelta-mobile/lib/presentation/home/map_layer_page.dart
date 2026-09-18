import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';

/// Screen representing "Mapa como Capa" from the ReVuelta design.
/// Features a segmented toggle [Devolver | Comercios], map canvas representation,
/// and contextual return points.
class MapLayerPage extends StatefulWidget {
  const MapLayerPage({super.key});

  @override
  State<MapLayerPage> createState() => _MapLayerPageState();
}

class _MapLayerPageState extends State<MapLayerPage> {
  int _selectedFilter = 0; // 0: Devolver, 1: Comercios

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EBE5),
      body: Stack(
        children: [
          // Background stylized map canvas simulation
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),

          // Map interactive points / pins
          Positioned(
            top: 220,
            left: 120,
            child: _MapPin(
              title: 'Café Central',
              isCurrent: true,
              onTap: () {},
            ),
          ),
          Positioned(
            top: 320,
            right: 80,
            child: _MapPin(
              title: 'Comedor Norte',
              isCurrent: false,
              onTap: () {},
            ),
          ),
          Positioned(
            top: 140,
            right: 110,
            child: _MapPin(
              title: 'Biblioteca Café',
              isCurrent: false,
              onTap: () {},
            ),
          ),

          // Top Header & Filter Segmented Control
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _FilterTabButton(
                              title: 'Devolver',
                              isSelected: _selectedFilter == 0,
                              onTap: () => setState(() => _selectedFilter = 0),
                            ),
                          ),
                          Expanded(
                            child: _FilterTabButton(
                              title: 'Comercios',
                              isSelected: _selectedFilter == 1,
                              onTap: () => setState(() => _selectedFilter = 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Floating Context Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Café Central',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '250 m \u2022 3 min caminando',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Punto de retorno habilitado \u2022 Acepta vasos y recipientes',
                      style: TextStyle(fontSize: 12, color: AppColors.darkGreen, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ruta hacia Café Central iniciada')),
                        );
                      },
                      child: const Text('Ir al punto de devolución'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String title;
  final bool isCurrent;
  final VoidCallback onTap;

  const _MapPin({
    required this.title,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primaryGreen : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              color: isCurrent ? Colors.white : AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final greenAreaPaint = Paint()
      ..color = const Color(0xFFD6E4D6)
      ..style = PaintingStyle.fill;

    // Parks / Green zones
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 100, size.width * 0.4, 180),
        const Radius.circular(24),
      ),
      greenAreaPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 300, size.width * 0.38, 220),
        const Radius.circular(24),
      ),
      greenAreaPaint,
    );

    // Roads
    final path = Path();
    path.moveTo(0, size.height * 0.35);
    path.lineTo(size.width, size.height * 0.42);

    path.moveTo(size.width * 0.45, 0);
    path.lineTo(size.width * 0.45, size.height);

    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.65);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
