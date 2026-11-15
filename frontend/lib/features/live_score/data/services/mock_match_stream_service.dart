import 'dart:async';

import '../../domain/models/match_model.dart';

class MockMatchStreamService {
  MockMatchStreamService({this.simulate = true}) {
    _matches = {for (final match in _createFixtures()) match.id: match};
    _updates = StreamController<MatchModel>.broadcast(
      onListen: _startTimer,
      onCancel: _stopTimer,
    );
  }

  final bool simulate;
  late final Map<String, MatchModel> _matches;
  late final StreamController<MatchModel> _updates;
  Timer? _timer;
  int _tick = 0;

  List<MatchModel> get initialMatches =>
      List<MatchModel>.unmodifiable(_matches.values);

  MatchModel? matchById(String id) => _matches[id];

  Stream<MatchModel> watchMatches() => _updates.stream;

  Stream<MatchModel> watchMatch(String id) =>
      _updates.stream.where((match) => match.id == id);

  void emitUpdate(MatchModel match) {
    if (_updates.isClosed || !_matches.containsKey(match.id)) return;
    _matches[match.id] = match;
    _updates.add(match);
  }

  void _startTimer() {
    if (!simulate || _timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _simulateTick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _simulateTick() {
    final liveMatches = _matches.values.where((match) => match.isLive).toList();
    if (liveMatches.isEmpty) return;

    final match = liveMatches[_tick % liveMatches.length];
    _tick++;
    final minute = (match.minute + 1).clamp(0, 90).toInt();
    final scoreChanged = _tick % 4 == 0;
    final homeScores = scoreChanged && _tick.isEven;
    final updated = match.copyWith(
      minute: minute,
      status: minute == 90 ? MatchStatus.finished : match.status,
      homeScore: match.homeScore + (homeScores ? 1 : 0),
      awayScore: match.awayScore + (scoreChanged && !homeScores ? 1 : 0),
    );
    emitUpdate(updated);
  }

  void dispose() {
    _stopTimer();
    _updates.close();
  }

  List<MatchModel> _createFixtures() {
    final today = DateTime.now();
    DateTime atDay(int offset, int hour, int minute) {
      final date = today.add(Duration(days: offset));
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    return [
      MatchModel(
        id: 'premier-arsenal-city',
        leagueId: 'premier-league',
        leagueName: 'Premier League',
        country: 'İngiltere',
        sport: SportKind.football,
        homeTeam: 'Arsenal',
        awayTeam: 'Manchester City',
        kickoff: atDay(0, 19, 30),
        status: MatchStatus.live,
        homeScore: 1,
        awayScore: 1,
        minute: 67,
      ),
      MatchModel(
        id: 'premier-liverpool-spurs',
        leagueId: 'premier-league',
        leagueName: 'Premier League',
        country: 'İngiltere',
        sport: SportKind.football,
        homeTeam: 'Liverpool',
        awayTeam: 'Tottenham',
        kickoff: atDay(0, 17, 0),
        status: MatchStatus.live,
        minute: 28,
      ),
      MatchModel(
        id: 'super-lig-galatasaray-fenerbahce',
        leagueId: 'super-lig',
        leagueName: 'Süper Lig',
        country: 'Türkiye',
        sport: SportKind.football,
        homeTeam: 'Galatasaray',
        awayTeam: 'Fenerbahçe',
        kickoff: atDay(0, 21, 45),
        status: MatchStatus.scheduled,
      ),
      MatchModel(
        id: 'champions-real-bayern',
        leagueId: 'champions-league',
        leagueName: 'Champions League',
        country: 'Avrupa',
        sport: SportKind.football,
        homeTeam: 'Real Madrid',
        awayTeam: 'Bayern Münih',
        kickoff: atDay(-1, 21, 0),
        status: MatchStatus.finished,
        homeScore: 2,
        awayScore: 1,
      ),
      MatchModel(
        id: 'euroleague-fener-olympiacos',
        leagueId: 'euroleague',
        leagueName: 'EuroLeague',
        country: 'Avrupa',
        sport: SportKind.basketball,
        homeTeam: 'Fenerbahçe Beko',
        awayTeam: 'Olympiacos',
        kickoff: atDay(0, 20, 0),
        status: MatchStatus.live,
        homeScore: 74,
        awayScore: 71,
        minute: 34,
      ),
      MatchModel(
        id: 'super-lig-besiktas-trabzonspor',
        leagueId: 'super-lig',
        leagueName: 'Süper Lig',
        country: 'Türkiye',
        sport: SportKind.football,
        homeTeam: 'Beşiktaş',
        awayTeam: 'Trabzonspor',
        kickoff: atDay(1, 19, 0),
        status: MatchStatus.scheduled,
      ),
    ];
  }
}
