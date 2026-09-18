import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';

/// Screen representing "Notificaciones" (Mockup Screen 10).
/// Lists reminders, return confirmations, drop-off point updates, and weekly summaries.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: const [
            _NotificationTile(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.forestGreen,
              title: 'Tu contenedor ha sido devuelto',
              subtitle: '#RV-0247 \u2022 Hoy, 11:24 a.m.',
            ),
            _NotificationTile(
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.warningOrange,
              title: 'Recordatorio de devolución',
              subtitle: 'Tienes un contenedor en uso hace 2 h.',
            ),
            _NotificationTile(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.forestGreen,
              title: 'Nuevo punto de retorno',
              subtitle: 'Ahora puedes devolver en la Biblioteca.',
            ),
            _NotificationTile(
              icon: Icons.eco_outlined,
              iconColor: AppColors.forestGreen,
              title: 'Impacto semanal',
              subtitle: '\u00A1Gracias por devolver 3 contenedores! Hace 1 d\u00EDa',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}
