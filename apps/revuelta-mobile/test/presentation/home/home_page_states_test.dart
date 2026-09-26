import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/application/operations/role_experience_providers.dart';
import 'package:revuelta_mobile/domain/auth/user_role.dart';
import 'package:revuelta_mobile/domain/auth/user_session.dart';
import 'package:revuelta_mobile/domain/failure/failure.dart';
import 'package:revuelta_mobile/domain/operations/role_experience.dart';
import 'package:revuelta_mobile/presentation/home/home_page.dart';

void main() {
  const session = UserSession(
    userId: 'participant-id',
    username: 'student1',
    role: UserRole.participant,
    token: 'token',
  );

  Widget pageWith(Future<PagedResult<ParticipantCirculation>> Function() load) {
    return ProviderScope(
      overrides: [myActiveCirculationsProvider.overrideWith((ref) => load())],
      child: const MaterialApp(home: HomePage(session: session)),
    );
  }

  testWidgets('renders loading state while active containers are requested',
      (tester) async {
    final pending = Completer<PagedResult<ParticipantCirculation>>();
    await tester.pumpWidget(pageWith(() => pending.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders typed network failure with retry action',
      (tester) async {
    await tester
        .pumpWidget(pageWith(() => Future.error(const NetworkFailure())));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión. Revisa la red e intenta nuevamente.'),
        findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('renders every active container returned by the server',
      (tester) async {
    final now = DateTime.parse('2026-09-26T12:00:00Z');
    final items = [
      ParticipantCirculation(
        circulationId: 'circulation-1',
        containerId: 'container-1',
        publicCode: 'RV-0001',
        containerState: 'IN_USE',
        stateLabel: 'En uso',
        deliveredAt: now,
        dueAt: now.add(const Duration(hours: 24)),
        status: 'ACTIVE',
      ),
      ParticipantCirculation(
        circulationId: 'circulation-2',
        containerId: 'container-2',
        publicCode: 'RV-0002',
        containerState: 'IN_USE',
        stateLabel: 'En uso',
        deliveredAt: now,
        dueAt: now.add(const Duration(hours: 24)),
        status: 'ACTIVE',
      ),
    ];
    await tester.pumpWidget(pageWith(() async => PagedResult(
          items: items,
          page: 0,
          size: 20,
          hasNext: false,
        )));
    await tester.pumpAndSettle();

    expect(find.text('2 recipientes en uso'), findsOneWidget);
    expect(find.textContaining('0001'), findsOneWidget);
    expect(find.textContaining('0002'), findsOneWidget);
  });
}
