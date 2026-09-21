import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:revuelta_mobile/presentation/scan/scan_page.dart';

void main() {
  testWidgets('requires the participant QR before the container QR',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ScanPage())),
    );

    expect(find.textContaining('Siempre se escanea primero'), findsOneWidget);
    expect(find.byType(MobileScanner), findsNothing);
    expect(find.byKey(const Key('start-dual-qr-scan')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
