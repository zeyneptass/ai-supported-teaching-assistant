import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Uygulama LoginScreen ile açılır ve sohbete geçer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Giriş Yap'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ogrenci@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'guvenli123',
    );
    await tester.tap(find.text('Giriş Yap'));
    await tester.pumpAndSettle();

    expect(find.text('Öğretim Asistanı'), findsOneWidget);
    expect(find.text('Çevrimiçi'), findsOneWidget);
    expect(find.text('Python list yapısı nedir?'), findsOneWidget);
    expect(find.text('Sorunuzu yazın...'), findsOneWidget);

    await tester.tap(find.byTooltip('Ders Notları'));
    await tester.pumpAndSettle();

    expect(find.text('TXT Dosyası Seç'), findsOneWidget);
    expect(find.text('Test Oluştur'), findsOneWidget);

    await tester.tap(find.byTooltip('Sohbete dön'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Canlı Sonuçlar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Canlı Sonuçlar'), findsOneWidget);
  });
}
