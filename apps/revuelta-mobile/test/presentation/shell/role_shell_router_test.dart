import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/domain/auth/user_role.dart';
import 'package:revuelta_mobile/domain/auth/user_session.dart';
import 'package:revuelta_mobile/application/operations/role_experience_providers.dart';
import 'package:revuelta_mobile/domain/operations/role_experience.dart';
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
      overrides: [
        myActiveCirculationsProvider.overrideWith(
          (ref) async => const PagedResult<ParticipantCirculation>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        myCirculationsProvider.overrideWith(
          (ref, status) async => const PagedResult<ParticipantCirculation>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        pendingWashesProvider.overrideWith(
          (ref) async => const PagedResult<PendingWash>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        recentOperatorOperationsProvider.overrideWith(
          (ref) async => const PagedResult<OperatorOperation>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        operationsSummaryProvider.overrideWith(
          (ref) async => const OperationsSummary(
            totalContainers: 0,
            registered: 0,
            available: 0,
            inUse: 0,
            returned: 0,
            damaged: 0,
            lost: 0,
            retired: 0,
            activeCirculations: 0,
          ),
        ),
        participantsProvider.overrideWith(
          (ref) async => const PagedResult<ParticipantDirectoryItem>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        containersProvider.overrideWith(
          (ref, query) async => const PagedResult<ContainerRecord>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        operationsCirculationsProvider.overrideWith(
          (ref) async => const PagedResult<OperationsCirculation>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
        operationsEventsProvider.overrideWith(
          (ref) async => const PagedResult<OperationsEvent>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
      ],
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
        find.text('No hay recipientes pendientes de lavado.'), findsOneWidget);
    expect(find.textContaining('backend'), findsNothing);
  });

  testWidgets('ADMIN opens the ReVuelta operations shell', (tester) async {
    await tester.pumpWidget(appFor(UserRole.admin));

    expect(find.byType(RevueltaOperationsShell), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(find.byType(CafeteriaShell), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Resumen'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
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
