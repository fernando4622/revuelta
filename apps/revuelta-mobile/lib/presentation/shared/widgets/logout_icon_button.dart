import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth/auth_notifier.dart';

class LogoutIconButton extends ConsumerWidget {
  const LogoutIconButton({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      key: const Key('logout-button'),
      tooltip: 'Cerrar sesión',
      icon: Icon(Icons.logout, color: color),
      onPressed: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        await ref.read(authNotifierProvider.notifier).logout();
      },
    );
  }
}
