import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Uygulama HomeScreen ile açılır ve ekranlar arasında gezinir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.pumpAndSettle();

    expect(find.text('Merhaba, Zeynep 👋'), findsOneWidget);
    expect(find.text('Ders notların'), findsOneWidget);
    expect(find.text('Hücre ve Organeller'), findsNothing);
    expect(find.byTooltip('Canlı Sonuçlar'), findsNothing);

    await tester.tap(find.byTooltip('Öğretim Asistanı'));
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
    expect(find.byTooltip('Canlı Sonuçlar'), findsNothing);
  });
}
