import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/auth/auth_notifier.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/shell/main_shell.dart';
import 'presentation/shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: ReVueltaApp()));
}

class ReVueltaApp extends ConsumerWidget {
  const ReVueltaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'ReVuelta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (session) {
          if (session != null) {
            return const MainShell();
          }
          return const LoginPage();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => const LoginPage(),
      ),
    );
  }
}
