import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import '../shell/main_shell.dart';

/// Screen representing "Bienvenida / Éxito" (Mockup Screen 10).
/// Shows sunburst celebration around container and "¡Bienvenido/a a ReVuelta! Ir al inicio".
class WelcomeSuccessPage extends StatelessWidget {
  const WelcomeSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Sunburst celebration container
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(
                      Icons.lunch_dining,
                      size: 80,
                      color: AppColors.forestGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Bienvenido/a\na ReVuelta!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ya eres parte del cambio.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  );
                },
                child: const Text('Ir al inicio'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
