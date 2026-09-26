import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/domain/auth/user_role.dart';
import 'package:revuelta_mobile/domain/auth/user_session.dart';
import 'package:revuelta_mobile/presentation/auth/login_options_page.dart';
import 'package:revuelta_mobile/presentation/history/history_page.dart';
import 'package:revuelta_mobile/presentation/home/home_page.dart';
import 'package:revuelta_mobile/presentation/impact/impact_page.dart';
import 'package:revuelta_mobile/presentation/notifications/notifications_page.dart';
import 'package:revuelta_mobile/application/operations/role_experience_providers.dart';
import 'package:revuelta_mobile/domain/operations/role_experience.dart';

void main() {
  const pilotLabel = 'Datos de demostración del piloto.';

  testWidgets('explicit mockup screens identify their pilot data',
      (tester) async {
    for (final page in <Widget>[
      const ImpactPage(),
      const NotificationsPage(),
    ]) {
      await tester.pumpWidget(MaterialApp(home: page));
      expect(find.text(pilotLabel), findsOneWidget);
    }
  });

  testWidgets('home uses the real empty state without demo controls',
      (tester) async {
    const session = UserSession(
      userId: 'participant-id',
      username: 'student1',
      role: UserRole.participant,
      token: 'token',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myActiveCirculationsProvider.overrideWith(
            (ref) async => const PagedResult<ParticipantCirculation>(
                items: [], page: 0, size: 20, hasNext: false),
          ),
        ],
        child: const MaterialApp(home: HomePage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tienes recipientes activos'), findsOneWidget);
    expect(find.text(pilotLabel), findsNothing);
    expect(find.byTooltip('Ver escenarios del piloto'), findsNothing);
  });

  testWidgets('history uses a real empty state', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        myCirculationsProvider.overrideWith(
          (ref, status) async => const PagedResult<ParticipantCirculation>(
              items: [], page: 0, size: 20, hasNext: false),
        ),
      ],
      child: const MaterialApp(home: HistoryPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay movimientos en esta vista.'), findsOneWidget);
    expect(find.text(pilotLabel), findsNothing);
  });

  testWidgets('deferred login options use pilot language', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginOptionsPage()));

    await tester.tap(find.text('Continuar con Google'));
    await tester.pump();

    expect(
      find.text('Acceso con Google no habilitado en esta etapa del piloto.'),
      findsOneWidget,
    );
    expect(find.textContaining('Demo UI'), findsNothing);
  });
}
