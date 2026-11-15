import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/services/mock_match_stream_service.dart';
import '../../domain/models/match_model.dart';

class LeagueSection {
  const LeagueSection({
    required this.id,
    required this.name,
    required this.country,
    required this.sport,
    required this.matches,
  });

  final String id;
  final String name;
  final String country;
  final SportKind sport;
  final List<MatchModel> matches;
}

class LiveScoreViewModel extends ChangeNotifier {
  LiveScoreViewModel(this._service) {
    _matches = _service.initialMatches;
    _latestMatches.addEntries(
      _matches.map((match) => MapEntry(match.id, match)),
    );
  }

  final MockMatchStreamService _service;
  late final List<MatchModel> _matches;
  final Map<String, MatchModel> _latestMatches = {};
  final Set<String> _collapsedLeagues = {};
  StreamSubscription<MatchModel>? _updates;
  DateTime _selectedDate = _dateOnly(DateTime.now());
  bool _liveOnly = false;
  bool _searchOpen = false;
  String _query = '';

  DateTime get selectedDate => _selectedDate;
  bool get liveOnly => _liveOnly;
  bool get searchOpen => _searchOpen;
  String get query => _query;
  int get liveMatchCount =>
      _latestMatches.values.where((match) => match.isLive).length;

  List<LeagueSection> get groupedMatches {
    final groups = <String, List<MatchModel>>{};
    for (final fixture in _matches) {
      final match = _latestMatches[fixture.id] ?? fixture;
      if (!_isSameDay(match.kickoff, _selectedDate)) continue;
      if (_liveOnly && !match.isLive) continue;
      if (!_matchesQuery(match)) continue;
      groups.putIfAbsent(match.leagueId, () => []).add(match);
    }

    return List<LeagueSection>.unmodifiable(
      groups.entries.map((entry) {
        final first = entry.value.first;
        return LeagueSection(
          id: entry.key,
          name: first.leagueName,
          country: first.country,
          sport: first.sport,
          matches: List<MatchModel>.unmodifiable(entry.value),
        );
      }),
    );
  }

  void start() {
    if (_updates != null) return;
    _updates = _service.watchMatches().listen(_onMatchUpdate);
  }

  void stop() {
    final updates = _updates;
    _updates = null;
    if (updates != null) unawaited(updates.cancel());
  }

  MatchModel? matchById(String id) => _latestMatches[id];

  Stream<MatchModel> watchMatch(String id) => _service.watchMatch(id);

  bool isLeagueExpanded(String id) => !_collapsedLeagues.contains(id);

  void selectDate(DateTime date) {
    final selected = _dateOnly(date);
    if (_isSameDay(selected, _selectedDate)) return;
    _selectedDate = selected;
    notifyListeners();
  }

  void setLiveOnly(bool value) {
    if (_liveOnly == value) return;
    _liveOnly = value;
    notifyListeners();
  }

  void toggleSearch() {
    _searchOpen = !_searchOpen;
    if (!_searchOpen) _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void toggleLeague(String id) {
    if (!_collapsedLeagues.add(id)) _collapsedLeagues.remove(id);
    notifyListeners();
  }

  void _onMatchUpdate(MatchModel match) {
    final previous = _latestMatches[match.id];
    _latestMatches[match.id] = match;
    if (previous?.status != match.status) notifyListeners();
  }

  bool _matchesQuery(MatchModel match) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return match.homeTeam.toLowerCase().contains(query) ||
        match.awayTeam.toLowerCase().contains(query) ||
        match.leagueName.toLowerCase().contains(query) ||
        match.country.toLowerCase().contains(query);
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  @override
  void dispose() {
    stop();
    _service.dispose();
    super.dispose();
  }
}
