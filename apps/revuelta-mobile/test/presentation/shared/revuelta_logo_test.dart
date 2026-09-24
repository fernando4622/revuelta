import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/presentation/shared/widgets/revuelta_logo.dart';

void main() {
  testWidgets('renders the approved ReVuelta logo asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevueltaLogo(width: 180),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, const AssetImage('resources/logo.jpeg'));
    expect(image.width, 180);
    expect(find.bySemanticsLabel('ReVuelta, cada vuelta cuenta'), findsOneWidget);
  });
}
