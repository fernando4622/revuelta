import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/revuelta_logo.dart';
import 'login_page.dart';
import 'register_page.dart';

/// Screen representing "Login - Opciones alternativas" (Mockup Screen 6).
/// Provides single sign-on buttons (Correo institucional, Google, Microsoft).
class LoginOptionsPage extends StatelessWidget {
  const LoginOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const RevueltaLogo(width: 190),
              const SizedBox(height: 36),

              const Text(
                'Inicia sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Button: Continuar con correo institucional
              ElevatedButton.icon(
                icon: const Icon(Icons.mail_outline, size: 20),
                label: const Text('Continuar con correo institucional'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Button: Continuar con Google
              OutlinedButton.icon(
                icon:
                    const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                label: const Text(
                  'Continuar con Google',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Inicio de sesión con Google (Demo UI)')),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Button: Continuar con Microsoft
              OutlinedButton.icon(
                icon: const Icon(Icons.window, size: 20, color: Colors.blue),
                label: const Text(
                  'Continuar con Microsoft',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Inicio de sesión con Microsoft (Demo UI)')),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes cuenta? ',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
