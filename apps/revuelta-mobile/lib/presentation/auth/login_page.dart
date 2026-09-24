import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../../domain/failure/failure.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/revuelta_logo.dart';

// ignore_for_file: deprecated_member_use

/// ReVuelta login backed by the authenticated session API.
/// Public registration and password recovery are intentionally not exposed.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      // ── Near-white sage background — exactly as in the mockup ──
      // Leaves are painted on top by _LoginOrganicBackgroundPainter
      backgroundColor: const Color(0xFFEEF5F0),
      body: Stack(
        children: [
          // 1. Corner botanical leaves (CustomPainter)
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginOrganicBackgroundPainter(),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: RevueltaLogo(width: 220)),
                            const SizedBox(height: 28),

                            // 1. Campo: Correo institucional / Usuario
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: const Color(0xFFCCDDD5), width: 1.2),
                              ),
                              child: TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF163A2E),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Correo institucional',
                                  hintStyle: TextStyle(
                                      color: Color(0xFF9BB0A5), fontSize: 15),
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF3F5E52),
                                    size: 22,
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 17),
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Ingresa tu correo o usuario'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2. Campo: Contraseña
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: const Color(0xFFCCDDD5), width: 1.2),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF163A2E),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Contraseña',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF9BB0A5), fontSize: 15),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF3F5E52),
                                    size: 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF3F5E52),
                                      size: 22,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 17),
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Ingresa tu contraseña'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Botón 1: Iniciar sesión (Dark Forest Green Pill Button)
                            authState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF163A2E)),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF163A2E),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 17),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: _submit,
                                    child: const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 14),

                            // Error Display
                            if (authState.hasError) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _loginErrorMessage(authState.error!),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],

                            // Footer Note: Solo para comunidad ITVer
                            const Text(
                              'Solo para comunidad ITVer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A9E94),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _loginErrorMessage(Object error) {
  if (error is! Failure) {
    return 'No fue posible iniciar sesión. Intenta nuevamente.';
  }

  return switch (error.code) {
    'INVALID_CREDENTIALS' =>
      'Usuario o contraseña incorrectos. Verifica tus datos.',
    'UNAUTHENTICATED' => 'Tu sesión expiró. Inicia sesión nuevamente.',
    'NETWORK_ERROR' => 'Sin conexión. Revisa la red e intenta nuevamente.',
    _ => 'No fue posible iniciar sesión. Intenta nuevamente.',
  };
}

/// Pixel-accurate replication of the decorative leaf background from the mockup.
///
/// Observations from the reference image:
/// - Background: near-white sage #EEF5F0
/// - Leaf fill:  sage green #B5CEC0 (semi-transparent)
/// - Leaves are lanceolate (pointed both ends), no visible midrib line
/// - 7 individual leaves placed in 5 positions around screen edges:
///   • Top-left:     2 long leaves pointing down-right from top-left corner
///   • Top-right:    2 leaves curving out from top-right corner
///   • Left-middle:  1 leaf at ~35% height on left edge, pointing right
///   • Bottom-left:  2 leaves pointing up-right from bottom-left corner
///   • Bottom-right: 2 leaves pointing up-left from bottom-right corner
class _LoginOrganicBackgroundPainter extends CustomPainter {
  static const _leafFill = Color(0xFFB5CEC0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = _leafFill
      ..style = PaintingStyle.fill;

    // ── TOP-LEFT: 2 leaves emerging from corner, pointing toward center-right
    // Leaf 1 — longer, more horizontal, tip ~30% across screen
    _leaf(
      canvas,
      paint,
      base: Offset(-8, 28),
      tip: Offset(w * 0.28, h * 0.10),
      width: 28,
    );
    // Leaf 2 — shorter, more vertical, slightly below leaf 1
    _leaf(
      canvas,
      paint,
      base: Offset(-5, 8),
      tip: Offset(w * 0.14, h * 0.18),
      width: 20,
    );

    // ── TOP-RIGHT: 2 leaves emerging from top-right corner
    // Leaf 1 — pointing down-left
    _leaf(
      canvas,
      paint,
      base: Offset(w + 8, 20),
      tip: Offset(w * 0.80, h * 0.13),
      width: 22,
    );
    // Leaf 2 — shorter, more to the right, partially clipped
    _leaf(
      canvas,
      paint,
      base: Offset(w + 5, 48),
      tip: Offset(w * 0.90, h * 0.06),
      width: 16,
    );

    // ── LEFT-MIDDLE: 1 leaf at ~35% height, pointing right into screen
    _leaf(
      canvas,
      paint,
      base: Offset(-10, h * 0.34),
      tip: Offset(w * 0.12, h * 0.30),
      width: 18,
    );

    // ── BOTTOM-LEFT: 2 leaves emerging from bottom-left corner
    // Leaf 1 — longer, pointing up-right
    _leaf(
      canvas,
      paint,
      base: Offset(-8, h - 20),
      tip: Offset(w * 0.22, h * 0.88),
      width: 26,
    );
    // Leaf 2 — shorter, more upward
    _leaf(
      canvas,
      paint,
      base: Offset(10, h + 5),
      tip: Offset(w * 0.10, h * 0.82),
      width: 18,
    );

    // ── BOTTOM-RIGHT: 2 leaves emerging from bottom-right corner
    // Leaf 1 — pointing up-left
    _leaf(
      canvas,
      paint,
      base: Offset(w + 8, h - 20),
      tip: Offset(w * 0.78, h * 0.88),
      width: 26,
    );
    // Leaf 2 — more upward, partially clipped
    _leaf(
      canvas,
      paint,
      base: Offset(w - 10, h + 5),
      tip: Offset(w * 0.90, h * 0.82),
      width: 18,
    );
  }

  /// Draws a lanceolate (pointed both ends) leaf from [base] to [tip].
  /// [width] controls the maximum belly width of the leaf.
  void _leaf(
    Canvas canvas,
    Paint paint, {
    required Offset base,
    required Offset tip,
    required double width,
  }) {
    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final len = (tip - base).distance;
    // Perpendicular direction
    final perpX = -dy / len;
    final perpY = dx / len;
    // Belly point at 55% along the leaf axis
    final belly = Offset(
      base.dx + dx * 0.55,
      base.dy + dy * 0.55,
    );

    final path = Path();
    path.moveTo(base.dx, base.dy);
    // Left curve: base → belly (shifted left) → tip
    path.quadraticBezierTo(
      belly.dx + perpX * width * 0.5,
      belly.dy + perpY * width * 0.5,
      tip.dx,
      tip.dy,
    );
    // Right curve: tip → belly (shifted right) → base
    path.quadraticBezierTo(
      belly.dx - perpX * width * 0.5,
      belly.dy - perpY * width * 0.5,
      base.dx,
      base.dy,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
