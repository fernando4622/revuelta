import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/domain/auth/user_role.dart';
import 'package:revuelta_mobile/domain/auth/user_session.dart';
import 'package:revuelta_mobile/presentation/shell/cafeteria_shell.dart';
import 'package:revuelta_mobile/presentation/shell/main_shell.dart';
import 'package:revuelta_mobile/presentation/shell/revuelta_operations_shell.dart';
import 'package:revuelta_mobile/presentation/shell/role_shell_router.dart';

void main() {
  Widget appFor(UserRole role) {
    final session = UserSession(
      userId: 'user-id',
      username: 'test-user',
      role: role,
      token: 'token',
    );

    return ProviderScope(
      child: MaterialApp(home: RoleShellRouter(session: session)),
    );
  }

  testWidgets('PARTICIPANT opens only the student shell', (tester) async {
    await tester.pumpWidget(appFor(UserRole.participant));

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(CafeteriaShell), findsNothing);
    expect(find.byType(RevueltaOperationsShell), findsNothing);
    expect(find.text('Impacto'), findsOneWidget);
  });

  testWidgets('OPERATOR opens the cafeteria shell on scan', (tester) async {
    await tester.pumpWidget(appFor(UserRole.operator));

    expect(find.byType(CafeteriaShell), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(find.byType(RevueltaOperationsShell), findsNothing);
    expect(find.text('Escanear ReVuelta'), findsOneWidget);
    expect(find.text('Impacto'), findsNothing);

    await tester.tap(find.text('Lavado'));
    await tester.pumpAndSettle();

    expect(
      find.text('Módulo de lavado pendiente durante esta etapa del piloto.'),
      findsOneWidget,
    );
    expect(find.textContaining('backend'), findsNothing);
  });

  testWidgets('ADMIN opens the ReVuelta operations shell', (tester) async {
    await tester.pumpWidget(appFor(UserRole.admin));

    expect(find.byType(RevueltaOperationsShell), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(find.byType(CafeteriaShell), findsNothing);
    expect(find.text('Resumen del piloto'), findsOneWidget);
    expect(
      find.text('Módulo pendiente durante esta etapa del piloto.'),
      findsOneWidget,
    );
    expect(find.textContaining('backend'), findsNothing);
  });

  testWidgets('unknown role opens no protected shell', (tester) async {
    await tester.pumpWidget(appFor(UserRole.unsupported));

    expect(find.byType(UnsupportedRolePage), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(find.byType(CafeteriaShell), findsNothing);
    expect(find.byType(RevueltaOperationsShell), findsNothing);
    expect(find.text('Acceso no disponible'), findsOneWidget);
    expect(
      find.text(
          'La cuenta test-user no tiene acceso habilitado para este piloto.'),
      findsOneWidget,
    );
  });
}
