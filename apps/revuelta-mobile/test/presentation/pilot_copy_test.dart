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

void main() {
  const pilotLabel = 'Datos de demostración del piloto.';

  testWidgets('mock data screens identify their pilot data', (tester) async {
    for (final page in <Widget>[
      const HistoryPage(),
      const ImpactPage(),
      const NotificationsPage(),
    ]) {
      await tester.pumpWidget(MaterialApp(home: page));
      expect(find.text(pilotLabel), findsOneWidget);
    }
  });

  testWidgets('home presents pilot scenarios without developer wording',
      (tester) async {
    const session = UserSession(
      userId: 'participant-id',
      username: 'student1',
      role: UserRole.participant,
      token: 'token',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomePage(session: session)),
      ),
    );

    expect(find.text(pilotLabel), findsOneWidget);
    await tester.tap(find.byTooltip('Ver escenarios del piloto'));
    await tester.pumpAndSettle();

    expect(find.text('Escenario: sin envases'), findsOneWidget);
    expect(find.text('Escenario: un envase'), findsOneWidget);
    expect(find.text('Escenario: varios envases'), findsOneWidget);
    expect(find.textContaining('Modo:'), findsNothing);
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
