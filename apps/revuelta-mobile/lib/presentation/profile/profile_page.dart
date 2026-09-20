import 'package:flutter/material.dart';
import '../../domain/auth/user_session.dart';
import '../notifications/notifications_page.dart';
import '../shared/theme/app_colors.dart';
import '../shared/widgets/logout_icon_button.dart';

/// Screen representing "Perfil" (Mockup Screen 9).
/// Shows student identity (Valeria Torres), avatar, and settings options.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.session,
  });

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    final username = session.username;

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
          const LogoutIconButton(),
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
                        username.isNotEmpty
                            ? username.substring(0, 1).toUpperCase()
                            : 'V',
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
                            session.role.displayName,
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

            // Logout Button
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Las opciones de cuenta se habilitarán cuando exista su contrato funcional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
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
