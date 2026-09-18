import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../../domain/failure/failure.dart';
import '../shared/theme/app_colors.dart';
import 'register_page.dart';
import 'splash_welcome_page.dart';

// ignore_for_file: deprecated_member_use

/// Pixel-perfect 100% faithful replication of the ReVuelta Login screen.
/// Features:
/// - Organic fluid sage background with corner botanical leaves
/// - Back arrow navigation
/// - Authentic ReVuelta leaf-loop mark and typography
/// - Bordered rounded text fields (Correo institucional, Contraseña con toggle de ojo)
/// - "¿Olvidaste tu contraseña?" link on right
/// - Solid dark forest-green "Iniciar sesión" pill button with backend Riverpod integration
/// - "o" divider and outlined "Crear cuenta" pill button
/// - "Solo para comunidad ITVer" footer
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
                // Top App Bar / Back Navigation Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF163A2E),
                        size: 26,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SplashWelcomePage()),
                          );
                        }
                      },
                    ),
                  ),
                ),

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
                            // ReVuelta Leaf Icon — large, no background circle
                            Center(
                              child: SizedBox(
                                width: 88,
                                height: 88,
                                child: CustomPaint(
                                  painter: _LoginLeafIconPainter(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Brand Name
                            const Text(
                              'ReVuelta',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF163A2E),
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            const Text(
                              'El ciclo de tu contenedor\nen tus manos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3F5E52),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // 1. Campo: Correo institucional / Usuario
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFCCDDD5), width: 1.2),
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
                                  hintStyle: TextStyle(color: Color(0xFF9BB0A5), fontSize: 15),
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
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Ingresa tu correo o usuario' : null,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2. Campo: Contraseña
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFCCDDD5), width: 1.2),
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
                                  hintStyle: const TextStyle(color: Color(0xFF9BB0A5), fontSize: 15),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF3F5E52),
                                    size: 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: const Color(0xFF3F5E52),
                                      size: 22,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Ingresa tu contraseña' : null,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Enlace: ¿Olvidaste tu contraseña?
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recuperación enviada a tu correo')),
                                  );
                                },
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3F5E52),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Botón 1: Iniciar sesión (Dark Forest Green Pill Button)
                            authState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(color: Color(0xFF163A2E)),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF163A2E),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 17),
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
                            const SizedBox(height: 20),

                            // Separador con 'o'
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0xFFD5E2D9), thickness: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'o',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3F5E52).withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0xFFD5E2D9), thickness: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Botón 2: Crear cuenta (Outlined Pill Button)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(color: Color(0xFF163A2E), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                                );
                              },
                              child: const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF163A2E),
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
                                  authState.error is Failure
                                      ? (authState.error as Failure).message
                                      : authState.error.toString(),
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
  static const _leafFill   = Color(0xFFB5CEC0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = _leafFill
      ..style = PaintingStyle.fill;

    // ── TOP-LEFT: 2 leaves emerging from corner, pointing toward center-right
    // Leaf 1 — longer, more horizontal, tip ~30% across screen
    _leaf(canvas, paint,
      base: Offset(-8, 28),
      tip:  Offset(w * 0.28, h * 0.10),
      width: 28,
    );
    // Leaf 2 — shorter, more vertical, slightly below leaf 1
    _leaf(canvas, paint,
      base: Offset(-5, 8),
      tip:  Offset(w * 0.14, h * 0.18),
      width: 20,
    );

    // ── TOP-RIGHT: 2 leaves emerging from top-right corner
    // Leaf 1 — pointing down-left
    _leaf(canvas, paint,
      base: Offset(w + 8, 20),
      tip:  Offset(w * 0.80, h * 0.13),
      width: 22,
    );
    // Leaf 2 — shorter, more to the right, partially clipped
    _leaf(canvas, paint,
      base: Offset(w + 5, 48),
      tip:  Offset(w * 0.90, h * 0.06),
      width: 16,
    );

    // ── LEFT-MIDDLE: 1 leaf at ~35% height, pointing right into screen
    _leaf(canvas, paint,
      base: Offset(-10, h * 0.34),
      tip:  Offset(w * 0.12, h * 0.30),
      width: 18,
    );

    // ── BOTTOM-LEFT: 2 leaves emerging from bottom-left corner
    // Leaf 1 — longer, pointing up-right
    _leaf(canvas, paint,
      base: Offset(-8, h - 20),
      tip:  Offset(w * 0.22, h * 0.88),
      width: 26,
    );
    // Leaf 2 — shorter, more upward
    _leaf(canvas, paint,
      base: Offset(10, h + 5),
      tip:  Offset(w * 0.10, h * 0.82),
      width: 18,
    );

    // ── BOTTOM-RIGHT: 2 leaves emerging from bottom-right corner
    // Leaf 1 — pointing up-left
    _leaf(canvas, paint,
      base: Offset(w + 8, h - 20),
      tip:  Offset(w * 0.78, h * 0.88),
      width: 26,
    );
    // Leaf 2 — more upward, partially clipped
    _leaf(canvas, paint,
      base: Offset(w - 10, h + 5),
      tip:  Offset(w * 0.90, h * 0.82),
      width: 18,
    );
  }

  /// Draws a lanceolate (pointed both ends) leaf from [base] to [tip].
  /// [width] controls the maximum belly width of the leaf.
  void _leaf(Canvas canvas, Paint paint, {
    required Offset base,
    required Offset tip,
    required double width,
  }) {
    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final len = (tip - base).distance;
    // Perpendicular direction
    final perpX = -dy / len;
    final perpY =  dx / len;
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
      tip.dx, tip.dy,
    );
    // Right curve: tip → belly (shifted right) → base
    path.quadraticBezierTo(
      belly.dx - perpX * width * 0.5,
      belly.dy - perpY * width * 0.5,
      base.dx, base.dy,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// Painter for the ReVuelta leaf loop logo mark on login
class _LoginLeafIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF163A2E);

    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Outer leaf loop
    path.moveTo(w * 0.5, h * 0.05);
    path.cubicTo(w * 0.9, h * 0.05, w * 0.95, h * 0.5, w * 0.75, h * 0.85);
    path.cubicTo(w * 0.6, h * 1.0, w * 0.25, h * 0.95, w * 0.1, h * 0.65);
    path.cubicTo(w * 0.02, h * 0.45, w * 0.15, h * 0.15, w * 0.5, h * 0.05);
    path.close();

    // Inner negative-space cutout
    final inner = Path();
    inner.moveTo(w * 0.48, h * 0.28);
    inner.cubicTo(w * 0.72, h * 0.28, w * 0.72, h * 0.58, w * 0.54, h * 0.72);
    inner.cubicTo(w * 0.32, h * 0.72, w * 0.28, h * 0.45, w * 0.48, h * 0.28);
    inner.close();

    final combined = Path.combine(PathOperation.difference, path, inner);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
