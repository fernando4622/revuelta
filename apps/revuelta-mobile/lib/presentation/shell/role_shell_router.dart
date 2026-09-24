import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_notifier.dart';
import '../../domain/auth/user_role.dart';
import '../../domain/auth/user_session.dart';
import '../shared/theme/app_colors.dart';
import 'cafeteria_shell.dart';
import 'main_shell.dart';
import 'revuelta_operations_shell.dart';

class RoleShellRouter extends StatelessWidget {
  const RoleShellRouter({
    super.key,
    required this.session,
  });

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    return switch (session.role) {
      UserRole.participant => MainShell(session: session),
      UserRole.operator => CafeteriaShell(session: session),
      UserRole.admin => RevueltaOperationsShell(session: session),
      UserRole.unsupported => UnsupportedRolePage(session: session),
    };
  }
}

class UnsupportedRolePage extends ConsumerWidget {
  const UnsupportedRolePage({
    super.key,
    required this.session,
  });

  final UserSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acceso no disponible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'La cuenta ${session.username} no tiene acceso habilitado para este piloto.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    key: const Key('unsupported-role-logout'),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
