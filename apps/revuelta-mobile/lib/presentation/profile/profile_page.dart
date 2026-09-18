import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../notifications/notifications_page.dart';
import '../shared/theme/app_colors.dart';

/// Screen representing "Perfil" (Mockup Screen 9).
/// Shows student identity (Valeria Torres), avatar, and settings options.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).value;
    final username = session?.username ?? 'Valeria Torres';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // User Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4E0DC),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'V',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${username.toLowerCase().replaceAll(' ', '.')}@universidad.edu',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile navigation options
            _ProfileOptionTile(
              icon: Icons.inventory_2_outlined,
              title: 'Mis contenedores',
              onTap: () {},
            ),
            _ProfileOptionTile(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: () {},
            ),
            _ProfileOptionTile(
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              onTap: () {},
            ),
            _ProfileOptionTile(
              icon: Icons.description_outlined,
              title: 'Términos y privacidad',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('CERRAR SESIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'ReVuelta v1.0.0 \u2022 Usa. Devuelve. Repite.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mintGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.forestGreen, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        onTap: onTap,
      ),
    );
  }
}
