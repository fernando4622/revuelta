import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../delivery/delivery_page.dart';
import '../return_flow/return_page.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/cycle_pulse_indicator.dart';
import '../shared/widgets/logout_icon_button.dart';

enum ScanMode {
  participantInformation,
  cafeteriaOperations,
}

/// Screen representing "Escáner que Transforma" from the ReVuelta design.
/// Features a viewfinder frame [  ], quick manual code fallback,
/// and smooth transformation card on container resolution.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({
    super.key,
    this.mode = ScanMode.participantInformation,
  });

  final ScanMode mode;

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final _codeController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _container;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _lookupContainer(String code) async {
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _container = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final data = await client.get('/containers/code/$code');
      setState(() {
        _container = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _container = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E272E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Escanear ReVuelta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: widget.mode == ScanMode.cafeteriaOperations
            ? const [LogoutIconButton(color: Colors.white)]
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Viewfinder Scanner area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Viewfinder frame with corners
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        // Corner brackets
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: CustomPaint(
                            painter: _ScannerFramePainter(
                                color: AppColors.primaryGreen),
                          ),
                        ),
                        if (_loading)
                          const CircularProgressIndicator(
                              color: AppColors.primaryGreen)
                        else
                          const Icon(
                            Icons.qr_code_scanner,
                            size: 72,
                            color: Colors.white30,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ajusta a una ReVuelta',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom drawer with Manual Lookup or Resolved Container Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Manual code lookup input
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Ingresar código (ej. RV-004281)',
                      prefixIcon: const Icon(Icons.qr_code),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search,
                            color: AppColors.primaryGreen),
                        onPressed: () =>
                            _lookupContainer(_codeController.text.trim()),
                      ),
                    ),
                    onSubmitted: (val) => _lookupContainer(val.trim()),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.errorRed, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                  color: AppColors.errorRed, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Resolved container card
                  if (_container != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CyclePulseIndicator(
                                  state: _container!['status'] ?? 'AVAILABLE',
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RV \u2022 ${_container!['code']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Estado: ${_container!['status']}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.darkGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.mode ==
                                ScanMode.cafeteriaOperations) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed: _container!['status'] ==
                                              'AVAILABLE'
                                          ? () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) => DeliveryPage(
                                                  initialContainerId:
                                                      _container!['id'],
                                                ),
                                              ));
                                            }
                                          : null,
                                      child: const Text('Entregar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.darkGreen,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed:
                                          _container!['status'] == 'IN_USE'
                                              ? () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (_) => ReturnPage(
                                                      initialContainerId:
                                                          _container!['id'],
                                                    ),
                                                  ));
                                                }
                                              : null,
                                      child: const Text('Devolver'),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Consulta informativa. Las entregas y devoluciones las confirma Cafetería.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  final Color color;

  _ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    final r = size.width;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(r, 0), Offset(r - cornerLength, 0), paint);
    canvas.drawLine(Offset(r, 0), Offset(r, cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, r), Offset(cornerLength, r), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r - cornerLength), paint);

    // Bottom-right
    canvas.drawLine(Offset(r, r), Offset(r - cornerLength, r), paint);
    canvas.drawLine(Offset(r, r), Offset(r, r - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
