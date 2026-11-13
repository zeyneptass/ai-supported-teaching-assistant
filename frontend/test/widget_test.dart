import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Uygulama LoginScreen ile açılır ve sohbete geçer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Giriş yap'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'ogrenci@example.com',
    );
    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();

    expect(find.text('Sohbet'), findsOneWidget);
    expect(find.text('Sorunuzu yazın...'), findsOneWidget);
  });
}
