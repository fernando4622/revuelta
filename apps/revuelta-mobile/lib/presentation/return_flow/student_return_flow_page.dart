import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';

/// Interactive multi-step student return experience based on Mockup Screens 3, 4, 5, 6:
/// - Step 0: Confirmar Devolución
/// - Step 1: Ruta / Ubicación al punto de retorno
/// - Step 2: Validación en tiempo real (Recibido -> Validando -> Disponible)
/// - Step 3: Éxito con impacto ambiental generado
class StudentReturnFlowPage extends StatefulWidget {
  final String containerCode;

  const StudentReturnFlowPage({
    super.key,
    this.containerCode = '#RV-0247',
  });

  @override
  State<StudentReturnFlowPage> createState() => _StudentReturnFlowPageState();
}

class _StudentReturnFlowPageState extends State<StudentReturnFlowPage> {
  int _currentStep = 0; // 0: Confirm, 1: Route, 2: Validation, 3: Success

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 3) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return 'Devolución';
      case 1:
        return 'Tu contenedor regresa';
      case 2:
        return 'Validando...';
      case 3:
        return 'Completado';
      default:
        return 'Devolución';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildConfirmStep();
      case 1:
        return _buildRouteStep();
      case 2:
        return _buildValidationStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildConfirmStep();
    }
  }

  /// Step 0: Confirmar Devolución (Mockup Screen 3)
  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container image / illustration
          Center(
            child: Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.lunch_dining,
                size: 64,
                color: AppColors.forestGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Contenedor ${widget.containerCode}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.forestGreen),
                  SizedBox(width: 6),
                  Text(
                    'En uso \u2022 Hace 42 min',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Location Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubicación actual',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: AppColors.forestGreen, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cafetería Central',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'A 2 min de ti',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text('Confirmar devolución'),
          ),
        ],
      ),
    );
  }

  /// Step 1: Ruta / Ubicación al punto de retorno (Mockup Screen 4)
  Widget _buildRouteStep() {
    return Column(
      key: const ValueKey(1),
      children: [
        // Simulated Campus Map Route View
        Expanded(
          child: Container(
            color: const Color(0xFFE3EDE8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _RouteMapPainter()),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.near_me, color: AppColors.forestGreen),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Punto de retorno',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      'Módulo de reciclaje - Cafetería',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'A 2 min',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Notification & Proceed Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_walk, color: AppColors.forestGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'En camino a la zona de retorno',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Tu contenedor será validado en cuanto llegue.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                ),
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('Llegué al punto de retorno'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 2: Validación en tiempo real (Mockup Screen 5)
  Widget _buildValidationStep() {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.lunch_dining,
                  size: 64,
                  color: AppColors.forestGreen,
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tu contenedor ha sido recibido',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Estamos validando que todo esté en orden.\nGracias por devolverlo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Lifecycle 3-step progress bar (Recibido -> Validando -> Disponible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ValidationStageNode(label: 'Recibido', isActive: true, isDone: true),
              _ValidationStageNode(label: 'Validando', isActive: true, isDone: false),
              _ValidationStageNode(label: 'Disponible', isActive: false, isDone: false),
            ],
          ),
          const SizedBox(height: 48),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
            ),
            onPressed: () => setState(() => _currentStep = 3),
            child: const Text('Ver confirmación e impacto'),
          ),
        ],
      ),
    );
  }

  /// Step 3: Éxito con impacto ambiental (Mockup Screen 6)
  Widget _buildSuccessStep() {
    return SingleChildScrollView(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: AppColors.forestGreen,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '\u00A1Gracias!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tu contenedor ha sido devuelto\ncorrectamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Impact Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impacto generado',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 24),
                  const _ImpactGeneratedRow(
                    icon: Icons.delete_outline,
                    value: '-1',
                    label: 'contenedor de un solo uso',
                  ),
                  const SizedBox(height: 12),
                  const _ImpactGeneratedRow(
                    icon: Icons.autorenew,
                    value: '-100%',
                    label: 'reutilización del contenedor',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    );
  }
}

class _ValidationStageNode extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _ValidationStageNode({
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    Color nodeColor = AppColors.cardBorder;
    if (isDone) nodeColor = AppColors.forestGreen;
    if (isActive && !isDone) nodeColor = AppColors.forestGreen;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? AppColors.forestGreen : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: nodeColor, width: 3),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : (isActive
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.forestGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.forestGreen : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ImpactGeneratedRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactGeneratedRow({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mintGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.forestGreen, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forestGreen,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.forestGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.forestGreen
      ..style = PaintingStyle.fill;

    // Start point
    final start = Offset(size.width * 0.35, size.height * 0.6);
    // End point
    final end = Offset(size.width * 0.7, size.height * 0.25);

    // Draw route path
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(size.width * 0.45, size.height * 0.4, end.dx, end.dy);

    canvas.drawPath(path, routePaint);

    // Draw start and end pin circles
    canvas.drawCircle(start, 8, dotPaint);
    canvas.drawCircle(end, 12, dotPaint);
    canvas.drawCircle(end, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
