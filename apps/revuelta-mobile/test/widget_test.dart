import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revuelta_mobile/application/auth/auth_notifier.dart';
import 'package:revuelta_mobile/domain/auth/user_session.dart';
import 'package:revuelta_mobile/domain/failure/failure.dart';
import 'package:revuelta_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReVueltaApp()));
    expect(find.byType(ReVueltaApp), findsOneWidget);
  });

  testWidgets('expired session returns to login with an explicit message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_ExpiredAuthNotifier.new),
        ],
        child: const ReVueltaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(
      find.text('Tu sesión expiró. Inicia sesión nuevamente.'),
      findsOneWidget,
    );
  });
}

class _ExpiredAuthNotifier extends AuthNotifier {
  @override
  Future<UserSession?> build() async => throw const SessionExpiredFailure();
}
