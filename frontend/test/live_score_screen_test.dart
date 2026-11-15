import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/live_score/data/services/mock_match_stream_service.dart';
import 'package:frontend/features/live_score/presentation/screens/live_score_screen.dart';
import 'package:frontend/features/live_score/presentation/screens/match_detail_screen.dart';
import 'package:frontend/features/live_score/presentation/viewmodels/live_score_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('groups matches and filters by date and live status', (
    tester,
  ) async {
    await _pumpScoreScreen(tester);

    expect(find.text('Canlı Sonuçlar'), findsOneWidget);
    expect(find.text('3 CANLI'), findsOneWidget);
    expect(find.text('Premier League'), findsOneWidget);
    expect(find.text('Süper Lig'), findsOneWidget);
    expect(find.text('Galatasaray'), findsOneWidget);

    await tester.tap(find.text('Sadece canlı'));
    await tester.pump();
    expect(find.text('Galatasaray'), findsNothing);
    expect(find.text('Arsenal'), findsOneWidget);

    await tester.tap(find.text('Sadece canlı'));
    await tester.pump();
    await tester.tap(find.text('Dün'));
    await tester.pump();
    expect(find.text('Champions League'), findsOneWidget);
    expect(find.text('Arsenal'), findsNothing);
  });

  testWidgets('updates an individual score and opens match details', (
    tester,
  ) async {
    final service = await _pumpScoreScreen(tester);
    final match = service.matchById('premier-arsenal-city')!;
    final scoreKey = const ValueKey('premier-arsenal-city-home-score');

    service.emitUpdate(match.copyWith(homeScore: 2));
    await tester.pump();

    expect(
      find.descendant(of: find.byKey(scoreKey), matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.text('Liverpool'), findsOneWidget);

    await tester.tap(find.text('Arsenal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(MatchDetailScreen), findsOneWidget);
    expect(find.text('İstatistikler'), findsOneWidget);
    expect(find.text('Kadro'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pump();
    expect(find.text('Canlı anlatım'), findsOneWidget);
  });
}

Future<MockMatchStreamService> _pumpScoreScreen(WidgetTester tester) async {
  final service = MockMatchStreamService(simulate: false);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => LiveScoreViewModel(service),
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const LiveScoreScreen(),
      ),
    ),
  );
  await tester.pump();
  return service;
}
