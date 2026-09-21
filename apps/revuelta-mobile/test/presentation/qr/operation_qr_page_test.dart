import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:revuelta_mobile/application/qr/qr_providers.dart';
import 'package:revuelta_mobile/application/qr/qr_repository.dart';
import 'package:revuelta_mobile/domain/qr/operation_qr.dart';
import 'package:revuelta_mobile/domain/qr/resolved_container_qr.dart';
import 'package:revuelta_mobile/presentation/qr/operation_qr_page.dart';

void main() {
  testWidgets('renders a scannable image for the server-issued QR',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrRepositoryProvider.overrideWithValue(_QrRepository()),
        ],
        child: const MaterialApp(home: OperationQrPage()),
      ),
    );

    await tester.tap(find.byKey(const Key('generate-delivery-qr')));
    await tester.pump();
    await tester.pump();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('ENTREGA'), findsOneWidget);
    expect(find.textContaining('También deberán escanear'), findsOneWidget);
  });
}

class _QrRepository implements QrRepository {
  @override
  Future<OperationQr> generateOperationQr(OperationQrPurpose purpose) async {
    final now = DateTime.now();
    return OperationQr(
      tokenRef: 'token-ref',
      purpose: purpose,
      payload: 'server-signed-payload',
      issuedAt: now,
      expiresAt: now.add(const Duration(minutes: 2)),
    );
  }

  @override
  Future<ResolvedContainerQr> resolveContainerQr(String payload) =>
      throw UnimplementedError();

  @override
  Future<ResolvedOperationQr> resolveOperationQr(String payload) =>
      throw UnimplementedError();
}
